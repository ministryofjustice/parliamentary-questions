require "rails_helper"

describe Users::OmniauthCallbacksController, type: :controller do
  let(:user_email) { "test.user@justice.gov.uk" }
  let(:user_name)  { "Test User" }
  let(:not_found_flash) { "Account not found or deactivated." }

  let(:auth_hash) do
    OmniAuth::AuthHash.new(
      "provider" => "entra_id",
      "uid" => "11111111-2222-3333-4444-555555555555",
      "info" => { "email" => user_email, "name" => user_name },
    )
  end

  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
    request.env["omniauth.auth"] = auth_hash
  end

  describe "GET entra_id" do
    context "when the user already exists and is active" do
      let!(:user) { create(:user, email: user_email, name: user_name) }

      it "signs the user in and redirects to the root path" do
        get :entra_id

        expect(controller.current_user).to eq(user)
        expect(response).to redirect_to(root_path)
      end

      it "does not create a new user" do
        expect { get :entra_id }.not_to change(User, :count)
      end
    end

    context "when Azure returns the email in a different case" do
      let!(:user) { create(:user, email: user_email, name: user_name) }
      let(:auth_hash) do
        OmniAuth::AuthHash.new(
          "provider" => "entra_id",
          "uid" => "11111111-2222-3333-4444-555555555555",
          "info" => { "email" => user_email.upcase, "name" => user_name },
        )
      end

      it "matches the existing user case-insensitively" do
        expect { get :entra_id }.not_to change(User, :count)

        expect(controller.current_user).to eq(user)
        expect(response).to redirect_to(root_path)
      end
    end

    context "when the user has been deactivated" do
      before { create(:user, email: user_email, name: user_name, deleted: true) }

      it "does not sign the user in" do
        get :entra_id

        expect(controller.current_user).to be_nil
        expect(flash[:alert]).to eq(not_found_flash)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when no matching user exists" do
      it "creates a new PQ user from the Azure profile and signs them in" do
        expect { get :entra_id }.to change(User, :count).by(1)

        user = User.find_by(email: user_email)
        expect(user.name).to eq(user_name)
        expect(user.roles).to eq(User::ROLE_PQ_USER)
        expect(controller.current_user).to eq(user)
        expect(response).to redirect_to(root_path)
      end

      context "and the Azure profile has no name" do
        let(:user_name) { nil }

        it "falls back to the local part of the email address" do
          get :entra_id

          expect(User.find_by(email: user_email).name).to eq("test.user")
        end
      end
    end

    context "when the auth hash has no email" do
      let(:auth_hash) do
        OmniAuth::AuthHash.new(
          "provider" => "entra_id",
          "uid" => "11111111-2222-3333-4444-555555555555",
          "info" => { "email" => nil, "name" => user_name },
        )
      end

      it "does not sign anyone in" do
        expect { get :entra_id }.not_to change(User, :count)

        expect(controller.current_user).to be_nil
        expect(flash[:alert]).to eq(not_found_flash)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "feature flag" do
      let!(:user) { create(:user, email: user_email, name: user_name) }

      context "when AUTH_METHODS=password_only" do
        before { set_auth_methods("password_only") }

        it "rejects the SSO callback" do
          get :entra_id

          expect(controller.current_user).to be_nil
          expect(flash[:alert]).to eq("Single sign-on is not enabled. Please sign in with your email and password.")
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context "when AUTH_METHODS=sso_only" do
        before { set_auth_methods("sso_only") }

        it "signs the user in" do
          get :entra_id

          expect(controller.current_user).to eq(user)
          expect(response).to redirect_to(root_path)
        end
      end

      context "when AUTH_METHODS=both" do
        before { set_auth_methods("both") }

        it "signs the user in" do
          get :entra_id

          expect(controller.current_user).to eq(user)
          expect(response).to redirect_to(root_path)
        end
      end
    end
  end
end
