require 'feature_helper'

feature 'Dashboard view', js: true, suspend_cleaner: true do
  include Features::PqHelpers

  before(:all) do
    DBHelpers.load_feature_fixtures
    @pqs = PQA::QuestionLoader.new.load_and_import(3)
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  def search_for(uin)
    create_pq_session
    visit dashboard_path
    fill_in 'Search by UIN', with: uin
    find('#search_button').click
  end
   
  scenario 'Parli-branch can view the questions tabled for today' do
    create_pq_session
    visit dashboard_path
    
    @pqs.each do |pq|
      within_pq(pq.uin) { expect(page).to have_content(pq.text) }
    end
  end

  scenario 'Parli-branch can find a question by uin' do
    uin = @pqs.first.uin
    search_for(uin)

    expect(page).to have_content(uin) 
    expect(page.current_path).to eq pq_path(uin)
  end

  scenario 'Parli-branch sees an error message if no question matches the uin' do
    search_for('gibberish')

    expect(page.current_path).to eq dashboard_path
    expect(page).to have_content "Question with UIN 'gibberish' not found"
  end
end
