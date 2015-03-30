require 'feature_helper'

feature 'Parliamentary Question view', js: true, suspend_cleaner: true do
  include Features::PqHelpers

  before(:all) do
    DBHelpers.load_feature_fixtures
    @pqs = PQA::QuestionLoader.new.load_and_import(3)
  end

  after(:all) do
    DatabaseCleaner.clean
  end


  context 'viewing a non-existent uin produces 404' do
    scenario 'GET show' do
      create_pq_session
      expect(LogStuff).to receive(:error).with(:error_page)

      visit pq_path("uin-#{100 + rand(5000)}")
      expect(page.status_code).to eq 404
      expect(page.title).to have_text("Not found (404)")
      expect(page).to have_content("The page you were looking for doesn't exist. (Error 404)")
    end

  end

end
