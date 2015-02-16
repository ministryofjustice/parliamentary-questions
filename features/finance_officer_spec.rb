require 'feature_helper'

# Pending test Senario 1
feature "Parli-branch invites a new finance officer" do
  xscenario "Parli-branch user invites a new user to be a finance officer in the PQ tool" do
  end
end

# Pending test Senario 2 
feature "New user recieves an email from Parli-branch and clicks on the accept the invitation link" do
  xscenario "On clicking the link the user is taken to a page on the tool to set their password" do
  end
  xscenario "After the password has been set by the Finance officer they are redirected to the list of questions" do
  end
end 

# Pending test Senario 3
feature "List of questions for the day have been set up" do
  xscenario "As a finance office i need to be able to log in and see the list of questions" do
  end
  xscenario "As a Finance officer I can sign out successfully of the PQ tool" do
  end
end
# 

# Actual testing Senario 4
feature "As a finance officer, I want to be able to register interest in a question", js: true do
  before do
    @pqs = PQA::QuestionLoader.new.load_and_import(3)
    create_finance_session
  end

# These tests are actioned on the following URL //finance/questions

  scenario "Finance officer tries to access the dashboard page" do
    visit dashboard_path
    expect(page).to have_content(/unauthorized/i)
  end

  context "Finance officer views daily questions" do
    scenario "Finance officer registers interest in some" do
      @pqs.each do |pq|
        expect(page).to have_content(pq.text)
      end

      check "pq[2][finance_interest]"
      click_link_or_button 'btn_finance_visibility'
      expect(page).to have_content(/successfully registered interest/i)
    end
  end
end

