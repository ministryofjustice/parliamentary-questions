require 'feature_helper'

feature "User filters early bird questions", js: true do

  before(:all) do
    DBHelpers.load_feature_fixtures
    generate_dummy_pq()
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  scenario 'Check filter elements are present' do
    create_pq_session

    click_link 'Settings'
    click_link 'Early bird list'
    click_link 'Early bird preview'

    expect(page).to have_text(:visible, 'New parliamentary questions to be allocated today')
    expect(page).to have_text('3 new parliamentary questions')

    expect(page).to have_text(:visible, 'uin-1')
    expect(page).to have_text(:visible, 'uin-2')
    expect(page).to have_text(:visible, 'uin-3')

    expect(page).to have_css('#sidebar')
    expect(page).to have_css('#filters')
    expect(find('#filters').find('h2')).to have_content('Filter')
    expect(html).to have_css('#question-type')
    expect(find('#filters .filter-box h3')).to have_content('Keywords')
    expect(find('#filters a')).to have_content("Today's PQs for all departments")
  end

  scenario 'Filter Early bird questions by question type' do
    create_pq_session
    visit early_bird_preview_path #'/early_bird/preview'

    click_button 'Question type'

    expect(html).not_to have_checked_field('Named Day')
    expect(html).not_to have_checked_field('Transferred')
    expect(html).not_to have_checked_field('I will write')

    page.choose('Named Day')
    expect(page).to have_checked_field('Named Day')

    expect(page).to have_text('1 selected')

    #save_and_open_page
    expect(html).to have_text('1 parliamentary question out of 3.')


    #expect(page).to have_text(:visible, 'uin-1')
    #expect(page).to have_text(:visible, 'uin-2')
    #expect(page).to have_text(:visible, 'uin-3')

    #find("input[value='Transferred']").set(true)
    #page.should have_css('#count', text: '<strong>1</strong> <span>parliamentary questions out of <strong>3</strong>.</span>')
    #expect(page).to have_text(:visible, 'uin-2')

    #find("input[value='I will write']").set(true)
    #page.should have_css('#count', text: '<strong>1</strong> <span>parliamentary questions out of <strong>3</strong>.</span>')
    #expect(page).to have_text(:visible, 'uin-3')

    #click_button 'Clear'

    #page.should have_css('#count', text: '<strong>3</strong> <span>parliamentary questions out of <strong>3</strong>.</span>')

  end

  private

  def generate_dummy_pq()
    pq1, pq2, pq3 = PQA::QuestionLoader.new.load_and_import(3)
    @uin1, @uin2, @uin3 = "uin-1", "uin-2", "uin-3"
    @question_type1, @question_type2, @question_type3 = "Named Day", "Transferred", "I will write"
    @question1, @question2, @question3 = "Contrary to popular belief, Lorem Ipsum is not simply random text.", "Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of de 'Finibus Bonorum et Malorum' (The Extremes of Good and Evil) by Cicero, written in 45 BC.", "This book is a treatise on the theory of ethics, very popular during the Renaissance."
    @member_name1, @member_name2, @member_name3 = "Diana Johnson", "John Smith", "Ann Jones"
    @member_constituency1, @member_constituency2, @member_constituency3 = "Kingston upon Hull North", "Wimbledon", "Canterbury"
  end
end
