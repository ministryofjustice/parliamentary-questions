require 'spec_helper'


feature 'Visit the dashboard an show the questions for the day' do
  before(:each) do
    import    = PQA::Import.new
    loader    = PQA::QuestionLoader.new
    question  = PQA::QuestionBuilder.default('uin-4')

    loader.load([question])
    import.run(Date.parse('1/1/2000'), Date.today)

    create_pq_session
  end

  scenario 'can view the questions tabled for today' do
    visit '/dashboard'
    expect(page).to have_content('uin-4')
  end
end
