require "feature_helper"

describe "Finance officer functions" do
  describe "Creating finance officers", js: true, suspend_cleaner: true do
    include Features::PqHelpers

    after do
      DatabaseCleaner.clean
    end

    let(:email) { "fo@pq.com"       }
    let(:name)  { "finance offer 1" }
    let(:pass)  { "123456789"       }

    it "Parli-branch can invite a new user to be a finance officer" do
      create_pq_session
      visit users_path
      click_on "Invite new user"

      fill_in "Email", with: email
      fill_in "Name", with: name
      select "FINANCE", from: "Role"
      click_on "Send an invitation"
      expect(page.title).to have_content("Users")
      expect(page).to have_content "An invitation email has been sent to #{email}"
    end

    it "New user receives an email invitation to become a finance officer" do
      user = User.find_by(email: "fo@pq.com")
      token = user.invitation_token
      invitation = DeviseMailer.invitation_instructions(user, token).deliver_now

      expect(invitation.govuk_notify_response.content["subject"]).to eq "Invitation instructions"
      expect(invitation.govuk_notify_response.content["body"]).to include "You have been invited to use the PQ Tracker"
    end

    it "Clicking the link allows the user to set their password" do
      user = User.find_by(email: "fo@pq.com")
      invitation_token, encoded = Devise.token_generator.generate(User, :invitation_token)
      user.update_column(:invitation_token, encoded)

      visit accept_user_invitation_path(invitation_token:)
      fill_in "Password", with: pass
      fill_in "Password confirmation", with: pass
      click_on "Set my password"

      expect(page.title).to have_content("New PQs today")
      expect(page).to have_content "Your password was set successfully. You are now signed in"
    end

    it "New finance officer can login to view a list of questions" do
      visit new_user_session_path

      fill_in "Email", with: email
      fill_in "Password", with: pass
      click_on "Sign in"

      expect(page.title).to have_content("New PQs today")
      expect(page).to have_content "New PQs today"
    end
  end

  describe "Registering interest in PQs as a Finance Officer", js: true do
    before do
      DBHelpers.load_feature_fixtures
      # @pqs = PQA::QuestionLoader.new.load_and_import(3)
      create_finance_session
    end

    let(:test_pqs) { PQA::QuestionLoader.new.load_and_import(3) }

    it "FO cannot access the dashboard page" do
      visit dashboard_path

      expect(page).to have_content(/unauthorized/i)
    end

    it "FO can register interest in PQs" do
      test_pqs.each do |pq|
        expect(page.title).to have_content("New PQs today")
        expect(page).to have_content(pq.text)
      end

      check "pq[2][finance_interest]"
      click_link_or_button "btn_finance_visibility"
      expect(page.title).to have_content("New PQs today")
      expect(page).to have_content(/successfully registered interest/i)
    end
  end
end
