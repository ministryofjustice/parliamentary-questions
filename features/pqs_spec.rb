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
	    visit pq_path(invalid_uin)
	    expect(page.status_code).to eq 404
	    expect(page).to have_content("The page you were looking for doesn't exist. (Error 404)")
	  end
	  
	end

end


def invalid_uin
	valid_uins = @pqs.map(&:uin)
	invalid_uin = nil
	while invalid_uin.nil? || valid_uins.include?(invalid_uin) do
		invalid_uin = generate_invalid_uin
	end
	invalid_uin
end

def generate_invalid_uin
	"uin-#{100 + rand(5000)}"
end

