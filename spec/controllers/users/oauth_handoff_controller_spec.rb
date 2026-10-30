require "rails_helper"

RSpec.describe Users::OauthHandoffController, type: :controller do
  render_views

  before { request.env["devise.mapping"] = Devise.mappings[:user] }

  # Devise's FailureApp sets flash[:timedout] and then redirects, so the flag
  # reaches the handoff through the session on the following request. Writing
  # it there reproduces that exactly; assigning to `flash` or
  # `controller.flash` before the action does not, because a controller spec
  # rebuilds the flash from the session for each request.
  def arrive_after_timeout
    session["flash"] = ActionDispatch::Flash::FlashHash.new("timedout" => true).to_session_value
  end

  def handoff_form
    response.body[/<form[^>]*oauth-handoff-form[^>]*>/]
  end

  describe "GET new" do
    it "renders a form that POSTs to the authorize path" do
      get :new

      expect(response.body).to include 'action="/users/auth/entra_id"'
      expect(response.body).to include 'method="post"'
    end

    it "includes an auto-submit script on a fresh arrival" do
      get :new

      expect(assigns(:mode)).to eq :fresh
      expect(response.body).to include "submit()"
    end

    # Without this split, sign-out and config.timeout_in have no observable
    # effect: the Entra session outlives the PQ one, so an auto-submitting page
    # hands the user straight back in and "Sign out" becomes a lie.
    it "omits the auto-submit script after a session timeout" do
      arrive_after_timeout

      get :new

      expect(assigns(:mode)).to eq :expired
      expect(response.body).not_to include "submit()"
    end

    it "omits the auto-submit script after an explicit sign out" do
      get :new, params: { signed_out: "1" }

      expect(assigns(:mode)).to eq :signed_out
      expect(response.body).not_to include "submit()"
    end

    # Review Focus 3: an auto-submitting page reachable by a signed-in user is
    # a redirect loop.
    it "redirects a signed-in user to root" do
      sign_in create(:user)

      get :new

      expect(response).to redirect_to root_path
    end

    it "renders no form at all for a signed-in user" do
      sign_in create(:user)

      get :new

      expect(response.body).not_to include "/users/auth/entra_id"
    end

    # The button is the no-JS and assistive-technology path, so it has to carry
    # visible text and must never be hidden.
    it "gives the button visible text in every mode" do
      [{}, { signed_out: "1" }].each do |params|
        get :new, params: params

        expect(response.body).to match(/<input[^>]+type="submit"[^>]+value="[^"]+"|<button[^>]*>\s*\S/)
      end
    end

    # Scoped to the handoff form: the surrounding layout legitimately contains
    # hidden elements, so scanning the whole page would test the template
    # rather than this page.
    it "does not hide the form" do
      get :new

      expect(handoff_form).to be_present
      expect(handoff_form).not_to match(/display:\s*none|\bhidden\b/)
    end

    # CSP sets script_src without 'unsafe-inline' and nonce_directives
    # script-src, so an un-nonced inline script would be blocked by the browser
    # and the auto-submit would silently never fire.
    it "nonces the auto-submit script" do
      get :new

      script = response.body[/<script[^>]*>/]
      expect(script).to match(/nonce="[^"]+"/)
    end

    it "shows progress wording on a fresh arrival rather than looking broken" do
      get :new

      expect(response.body).to include I18n.t("users.oauth_handoff.fresh.heading")
    end

    it "confirms the sign out rather than bouncing the user back in" do
      get :new, params: { signed_out: "1" }

      expect(response.body).to include I18n.t("users.oauth_handoff.signed_out.heading")
    end

    it "says the session expired after a timeout" do
      arrive_after_timeout

      get :new

      expect(response.body).to include I18n.t("users.oauth_handoff.expired.heading")
    end
  end
end
