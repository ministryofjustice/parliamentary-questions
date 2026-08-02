require "feature_helper"

describe "Sign in page and authentication modes", type: :feature do
  let(:sso_button_text) { "Sign in with your Justice account" }

  describe "sign in page" do
    context "when AUTH_METHODS=both (default)" do
      it "offers both password sign in and SSO" do
        visit new_user_session_path

        expect(page).to have_field("Email (required)")
        expect(page).to have_field("Password (required)")
        expect(page).to have_button("Sign in")
        expect(page).to have_button(sso_button_text)
      end
    end

    context "when AUTH_METHODS=sso_only" do
      before { set_auth_methods("sso_only") }

      it "offers only SSO" do
        visit new_user_session_path

        expect(page).to have_no_field("Email (required)")
        expect(page).to have_no_field("Password (required)")
        expect(page).to have_button(sso_button_text)
      end
    end

    context "when AUTH_METHODS=password_only" do
      before { set_auth_methods("password_only") }

      it "offers only password sign in" do
        visit new_user_session_path

        expect(page).to have_field("Email (required)")
        expect(page).to have_field("Password (required)")
        expect(page).to have_button("Sign in")
        expect(page).to have_no_button(sso_button_text)
      end
    end
  end

  describe "signing in with Azure Entra ID" do
    let(:user) { DbHelpers.users.find(&:pq_user?) }

    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:entra_id] = OmniAuth::AuthHash.new(
        "provider" => "entra_id",
        "uid" => "11111111-2222-3333-4444-555555555555",
        "info" => { "email" => user.email, "name" => user.name },
      )
    end

    after do
      OmniAuth.config.mock_auth[:entra_id] = nil
      OmniAuth.config.test_mode = false
    end

    it "signs an existing user in via the SSO button and shows the dashboard" do
      visit new_user_session_path
      click_button sso_button_text

      expect(page).to have_current_path(dashboard_path, ignore_query: true)
    end

    context "when no matching account exists" do
      before do
        OmniAuth.config.mock_auth[:entra_id] = OmniAuth::AuthHash.new(
          "provider" => "entra_id",
          "uid" => "11111111-2222-3333-4444-555555555555",
          "info" => { "email" => "brand.new.user@justice.gov.uk", "name" => "Brand New User" },
        )
      end

      it "creates the account and signs the user in" do
        visit new_user_session_path

        expect { click_button sso_button_text }.to change(User, :count).by(1)
        expect(page).to have_current_path(dashboard_path, ignore_query: true)
      end
    end
  end

  describe "signing in with a password" do
    it "still works when AUTH_METHODS=both" do
      create_pq_session

      expect(page).to have_current_path(dashboard_path, ignore_query: true)
    end
  end
end
