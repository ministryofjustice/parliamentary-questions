require 'feature_helper'

feature 'Visit the dashboard an show the questions for the day' do
  before(:each) do
    @pq, _ = PQA::QuestionLoader.new.load_and_import
    create_pq_session
  end

  scenario 'can view the questions tabled for today' do
    visit '/dashboard'
    expect(page).to have_content(@pq.text)
  end
end
