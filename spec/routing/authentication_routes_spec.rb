require "rails_helper"

RSpec.describe "authentication routes", type: :routing do
  # Routes are drawn at boot, so each context has to redraw them against a
  # stubbed flag. Restoring the real table afterwards is essential:
  # config.order = "random", so a leaked route table breaks an arbitrary
  # unrelated spec in a way that is painful to track down.
  around do |example|
    example.run
  ensure
    Rails.application.reload_routes!
  end

  def redraw_with_password_login(enabled)
    allow(Settings).to receive(:password_login_enabled?).and_return(enabled)
    Rails.application.reload_routes!
  end

  context "when password login is disabled" do
    before { redraw_with_password_login(false) }

    # Keeping the route NAME new_user_session pointed at the handoff is what
    # makes automatic entry work without touching anything else: Devise's
    # authenticate_user! failure path already redirects there, and
    # stored_location_for already captures the original destination.
    it "routes GET /users/sign_in to the handoff" do
      expect(get: "/users/sign_in").to route_to("users/oauth_handoff#new")
    end

    it "keeps the new_user_session route name" do
      expect(Rails.application.routes.url_helpers.new_user_session_path)
        .to eq "/users/sign_in"
    end

    it "does not route the password form" do
      expect(post: "/users/sign_in").not_to be_routable
    end

    it "does not route the password reset form" do
      expect(get: "/users/password/new").not_to be_routable
    end

    it "does not route the unlock form" do
      expect(get: "/users/unlock/new").not_to be_routable
    end

    it "does not route invitation acceptance" do
      expect(get: "/users/invitation/accept").not_to be_routable
    end

    # Only one way into an auto-submitting page. /users/sign_in is it.
    #
    # Asserted as "does not reach the handoff" rather than "is not routable":
    # `resources :users` matches /users/:id, so any single-segment /users/*
    # path is still claimed by users#show (with id: "oauth_handoff", which is
    # authenticated and then 404s). The multi-segment password paths below are
    # genuinely unroutable because they do not fit that pattern.
    it "does not also expose the handoff on its own path" do
      expect(get: "/users/oauth_handoff").not_to route_to("users/oauth_handoff#new")
    end

    it "still routes sign out" do
      expect(Devise.sign_out_via => "/users/sign_out")
        .to route_to("users/sessions#destroy")
    end

    it "still routes the OmniAuth callback" do
      expect(get: "/users/auth/entra_id/callback")
        .to route_to("users/omniauth_callbacks#entra_id")
    end

    it "still routes the OmniAuth authorize path" do
      expect(post: "/users/auth/entra_id").to be_routable
    end
  end

  context "when password login is enabled" do
    before { redraw_with_password_login(true) }

    it "routes GET /users/sign_in to the password form" do
      expect(get: "/users/sign_in").to route_to("users/sessions#new")
    end

    it "routes the password reset form" do
      expect(get: "/users/password/new").to be_routable
    end

    it "routes invitation acceptance" do
      expect(get: "/users/invitation/accept").to be_routable
    end

    # The flags are independent, so turning the password form back on must not
    # take the OAuth journey away with it.
    it "still exposes the handoff on its own path" do
      expect(get: "/users/oauth_handoff").to route_to("users/oauth_handoff#new")
    end

    it "still routes the OmniAuth callback" do
      expect(get: "/users/auth/entra_id/callback")
        .to route_to("users/omniauth_callbacks#entra_id")
    end
  end
end
