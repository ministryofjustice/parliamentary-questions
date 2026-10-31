require "rails_helper"
require "devise"

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  let(:tenant_id) { "tenant-abc" }
  let(:client_id) { "client-abc" }
  let(:issuer)    { "https://login.microsoftonline.com/tenant-abc/v2.0" }
  let(:oid)       { "00000000-1111-2222-3333-444444444444" }

  # AzureOauth::Claims fails closed when the tenant is unconfigured, and the
  # test environment carries no Azure credentials, so these stubs are required
  # for any example that expects a successful sign-in.
  before do
    allow(Settings).to receive_messages(
      omniauth_azure_tenant_id: tenant_id,
      omniauth_azure_client_id: client_id,
      azure_issuer: issuer,
    )

    request.env["devise.mapping"] = Devise.mappings[:user]
    request.env["omniauth.auth"] = auth_hash
  end

  def auth_hash(**claims)
    raw_info = {
      "oid" => oid,
      "tid" => tenant_id,
      "aud" => client_id,
      "iss" => issuer,
      "email" => "jane.smith@justice.gov.uk",
      "name" => "Jane Smith",
    }.merge(claims.transform_keys(&:to_s))

    OmniAuth::AuthHash.new(
      provider: "entra_id",
      uid: raw_info["oid"],
      info: { name: raw_info["name"], email: raw_info["email"] },
      extra: { raw_info: raw_info },
    )
  end

  def warnings_from
    messages = []
    allow(LogStuff).to receive(:warn) { |*_args, &block| messages << block.call }
    yield
    messages.join("\n")
  end

  describe "GET entra_id" do
    it "signs in a user whose oid is known" do
      user = create(:user, email: "jane.smith@justice.gov.uk", name: "Jane", azure_oid: oid)

      get :entra_id

      expect(controller.current_user).to eq user
    end

    it "auto-provisions an unknown tenant user as a PQ user" do
      expect { get :entra_id }.to change(User, :count).by(1)

      expect(controller.current_user.roles).to eq User::ROLE_PQ_USER
    end

    it "redirects to the stored location when one was saved" do
      create(:user, email: "jane.smith@justice.gov.uk", name: "Jane", azure_oid: oid)
      session["user_return_to"] = "/pqs/42"

      get :entra_id

      expect(response).to redirect_to "/pqs/42"
    end

    it "redirects to root when no location was stored" do
      create(:user, email: "jane.smith@justice.gov.uk", name: "Jane", azure_oid: oid)

      get :entra_id

      expect(response).to redirect_to root_path
    end

    # Devise does not rotate the session on sign-in by itself, which is why
    # Users::SessionsController#create does it explicitly for passwords.
    it "discards the pre-authentication session" do
      create(:user, email: "jane.smith@justice.gov.uk", name: "Jane", azure_oid: oid)
      session[:planted_before_sign_in] = "fixation"

      get :entra_id

      expect(session[:planted_before_sign_in]).to be_nil
    end

    # The ordering is the whole point: stored_location_for reads the session,
    # so capturing it after reset_session would silently lose every deep link.
    it "preserves the stored location across the session reset" do
      create(:user, email: "jane.smith@justice.gov.uk", name: "Jane", azure_oid: oid)
      session["user_return_to"] = "/pqs/42"
      session[:planted_before_sign_in] = "fixation"

      get :entra_id

      expect(response).to redirect_to "/pqs/42"
      expect(session[:planted_before_sign_in]).to be_nil
    end

    it "handles the developer strategy with the same action as the real provider" do
      expect(described_class.instance_method(:developer).original_name).to eq :entra_id
    end

    context "when the claims are refused" do
      it "redirects to the failure page when the tenant does not match" do
        request.env["omniauth.auth"] = auth_hash(tid: "another-tenant")

        get :entra_id

        expect(response).to redirect_to sign_in_failed_path
      end

      it "redirects to the failure page when the audience does not match" do
        request.env["omniauth.auth"] = auth_hash(aud: "another-client")

        get :entra_id

        expect(response).to redirect_to sign_in_failed_path
      end

      it "redirects to the failure page when the issuer does not match" do
        request.env["omniauth.auth"] = auth_hash(iss: "https://login.microsoftonline.com/elsewhere/v2.0")

        get :entra_id

        expect(response).to redirect_to sign_in_failed_path
      end

      it "redirects to the failure page when the oid is missing" do
        request.env["omniauth.auth"] = auth_hash(oid: "  ")

        get :entra_id

        expect(response).to redirect_to sign_in_failed_path
      end

      it "does not sign anyone in when validation fails" do
        request.env["omniauth.auth"] = auth_hash(tid: "another-tenant")

        get :entra_id

        expect(controller.current_user).to be_nil
      end

      it "creates no user when validation fails" do
        request.env["omniauth.auth"] = auth_hash(tid: "another-tenant")

        expect { get :entra_id }.not_to change(User, :count)
      end

      it "logs the reason without rendering it" do
        request.env["omniauth.auth"] = auth_hash(tid: "another-tenant")

        output = warnings_from { get :entra_id }

        expect(output).to include "tenant_mismatch"
        expect(response).to redirect_to sign_in_failed_path
        expect(response.body).not_to include "tenant_mismatch"
      end
    end

    context "when the identity conflicts with an existing account" do
      it "redirects to the failure page" do
        create(:user, email: "jane.smith@justice.gov.uk", name: "Jane", azure_oid: "someone-elses-oid")

        get :entra_id

        expect(response).to redirect_to sign_in_failed_path
      end

      it "does not sign anyone in" do
        create(:user, email: "jane.smith@justice.gov.uk", name: "Jane", azure_oid: "someone-elses-oid")

        get :entra_id

        expect(controller.current_user).to be_nil
      end

      it "logs the conflict" do
        create(:user, email: "jane.smith@justice.gov.uk", name: "Jane", azure_oid: "someone-elses-oid")

        output = warnings_from { get :entra_id }

        expect(output).to include oid
      end
    end
  end

  # #failure has no route of its own: Devise sets OmniAuth.config.on_failure to
  # a proc that calls `controller_klass.action(:failure).call(env)` directly.
  # These examples therefore supply a minimal route set so the action can be
  # dispatched, which is the only practical way to construct the specific env
  # shapes below. That a real provider failure reaches this action and lands on
  # the error page is proven end-to-end in
  # spec/requests/omniauth_request_phase_spec.rb instead.
  describe "GET failure" do
    # RouteSet#draw calls clear! first, so this wipes the application's routes
    # for the duration of the example. Restoring them afterwards is essential:
    # config.order = "random", so a leaked route table breaks an unrelated spec
    # in a way that is painful to track down.
    before do
      routes.draw do
        get "/sign_in_failed", to: "errors#sign_in_failed"
        get "/users/auth/failure", to: "users/omniauth_callbacks#failure"
      end
    end

    after { Rails.application.reload_routes! }

    it "redirects to the failure page" do
      request.env["omniauth.error.type"] = :invalid_credentials

      get :failure

      expect(response).to redirect_to sign_in_failed_path
    end

    # Review Focus 4: on access_denied — a user clicking "Cancel" at the
    # Microsoft prompt — OmniAuth sets a type but no exception object, so any
    # #failure reading omniauth.error.message raises NoMethodError and turns a
    # routine cancellation into a 500. Devise's own implementation also calls
    # failed_strategy.name, which is nil here.
    it "survives a failure with no error object" do
      request.env["omniauth.error.type"] = :access_denied
      request.env["omniauth.error"] = nil

      expect { get :failure }.not_to raise_error
      expect(response).to redirect_to sign_in_failed_path
    end

    it "survives a failure with no error type at all" do
      expect { get :failure }.not_to raise_error
      expect(response).to redirect_to sign_in_failed_path
    end

    it "sets no flash carrying provider-supplied text" do
      request.env["omniauth.error.type"] = :invalid_credentials

      get :failure

      expect(flash[:alert]).to be_nil
    end

    it "logs the failure type" do
      request.env["omniauth.error.type"] = :access_denied

      output = warnings_from { get :failure }

      expect(output).to include "access_denied"
    end
  end
end
