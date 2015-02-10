require 'feature_helper'

# Senario 1
# pq user invites a new user as a finance officer in the PQ tool 

# Senario 2 
# user recieve an email and clicks on the accept the invitation link and sets their password, and see the list of questions

# Senario 3
# as a finance office i need to be able to log in and see the list of questions

# Senario 4
feature "As a finance officer, I want to be able to register interest in a question", js: true do
  before do
    @pqs = PQA::QuestionLoader.new.load_and_import(3)
    create_finance_session
  end

# These tests are actioned on the following URL //finance/questions

  scenario "Finance officer tries to access the dashboard page" do
    visit '/dashboard'
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

# Senario 5
# Finance officer I can sign out successfully of the PQ tool