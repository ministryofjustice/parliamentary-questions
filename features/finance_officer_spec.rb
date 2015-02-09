require 'feature_helper'

feature "As a finance officer, I want to be able to register interest in a question", js: true do
  before do
    @pqs = PQA::QuestionLoader.new.load_and_import(3)
    create_finance_session
  end

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
