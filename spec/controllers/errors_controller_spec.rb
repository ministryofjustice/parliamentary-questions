# rails_helper rather than spec_helper: `render_views` below renders the
# application layout, whose navigation partial calls current_user, and that
# needs Devise::Test::ControllerHelpers to inject a Warden proxy. This also
# brings the file in line with the other 12 controller specs.
require "rails_helper"

RSpec.describe ErrorsController, type: :controller do
  context "when not found" do
    it "renders the expected template" do
      get :not_found
      expect(response).to render_template(:not_found)
    end

    it "is successful" do
      get :not_found
      expect(response).to be_not_found
    end
  end

  context "when internal error" do
    it "renders the expected template" do
      get :internal_error
      expect(response).to render_template(:internal_error)
    end

    it "is successful" do
      get :internal_error
      expect(response.status).to eq 500
    end
  end

  # config.exceptions_app is the route set, and ShowExceptions rewrites
  # PATH_INFO to "/<status>". Without a /422 route, an
  # ActionController::InvalidAuthenticityToken — which Rails maps to 422 —
  # found nothing to render and the user got a completely blank page. That is
  # reachable by a legitimate user: the handoff's signed-out and expired modes
  # deliberately wait for a click, so the page can sit open long enough for its
  # token to go stale.
  context "when the request could not be processed" do
    render_views

    it "renders the expected template" do
      get :unprocessable_content

      expect(response).to render_template(:unprocessable_content)
    end

    it "responds 422" do
      get :unprocessable_content

      expect(response.status).to eq 422
    end

    it "is not blank, and points the user at support" do
      get :unprocessable_content

      expect(response.body).to include Settings.mail_tech_support
    end
  end

  context "when sign in failed" do
    # Controller specs do not render views by default, which would make every
    # body assertion below pass against an empty string.
    render_views

    it "renders the expected template" do
      get :sign_in_failed
      expect(response).to render_template(:sign_in_failed)
    end

    it "responds forbidden" do
      get :sign_in_failed
      expect(response).to be_forbidden
    end

    # Echoing a provider-supplied error_description into a PQ-branded page is a
    # reflected-content vector. The page takes nothing from params at all.
    it "does not render provider-supplied text" do
      get :sign_in_failed, params: { error_description: "<script>alert(1)</script>" }
      expect(response.body).not_to include "alert(1)"
    end

    it "directs the user to the support address from Settings" do
      get :sign_in_failed
      expect(response.body).to include Settings.mail_tech_support
    end

    # A retry link on the page you reach by failing a retry is how you build a
    # loop: the handoff auto-submits, so a link back into it would spin.
    it "offers no route back into the sign-in journey" do
      get :sign_in_failed

      expect(response.body).not_to include "/users/sign_in"
      expect(response.body).not_to include "/users/auth/"
    end

    it "says nothing about which check failed" do
      get :sign_in_failed

      expect(response.body).not_to match(/\b(tenant|audience|issuer|oid)\b/i)
    end
  end
end
