require 'feature_helper'

feature "User filters early bird questions", js: true, suspend_cleaner: true do

  before(:all) do
    DBHelpers.load_feature_fixtures
    generate_dummy_pq()

    # Change Q1 properties
    a = Pq.first
    a.update(question: 'Contrary to popular belief, Lorem Ipsum is not simply random text.')
    a.update(member_name: 'John Smith')
    a.update(member_constituency: 'Canterbury')

    # Change Q2 properties
    a = Pq.second
    a.update(transferred: true)
    a.update(question: 'Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC.')
    a.update(member_name: 'Sally Merton')
    a.update(member_constituency: 'Wimbledon')

    # Change Q3 properties
    a = Pq.third
    a.update(question_type: 'Ordinary')
    a.update(question: 'This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.')
    a.update(member_name: 'Anne Day')
    a.update(member_constituency: 'Kingston upon Hull North')
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  scenario 'Check filter elements are present' do
    create_pq_session

    visit early_bird_preview_path #'/early_bird/preview'

    expect(page).to have_text(:visible, 'New parliamentary questions to be allocated today')
    expect(page).to have_text('3 new parliamentary questions')

    expect(page).to have_text('uin-1')
    expect(page).to have_text('uin-2')
    expect(page).to have_text('uin-3')

    expect(page).to have_css('#sidebar')
    expect(page).to have_css('#filters')
    expect(find('#filters').find('h2')).to have_content('Filter')
    expect(html).to have_css('#question-type')
    expect(find('#filters .filter-box h3')).to have_content('Keywords')
    expect(find('#filters a')).to have_content("Today's PQs for all departments")
  end

  scenario 'Filter questions by question type' do
    create_pq_session
    visit early_bird_preview_path #'/early_bird/preview'

    click_button 'Question type'

    expect(html).not_to have_checked_field('Named Day')
    expect(html).not_to have_checked_field('Ordinary')
    expect(html).not_to have_checked_field('Transferred in')

    page.choose('Named Day')
    expect(page).to have_text('1 selected')
    expect(page).to have_text('2 parliamentary questions out of 3.')

    page.choose('Ordinary')
    expect(page).to have_text('1 selected')
    expect(page).to have_text('1 parliamentary question out of 3.')

    page.choose('Transferred in')
    expect(page).to have_text('1 selected')
    expect(page).to have_text('1 parliamentary question out of 3.')

    click_button('clear-type-filter')
    expect(html).not_to have_checked_field('Named Day')
    expect(html).not_to have_checked_field('Ordinary')
    expect(html).not_to have_checked_field('Transferred in')
    expect(page).not_to have_text('1 selected')

    expect(page).to have_text('3 parliamentary questions out of 3.')
  end

  scenario 'Filter questions by keyword' do
    create_pq_session
    visit early_bird_preview_path #'/early_bird/preview'

    expect(page).to have_text('3 new parliamentary questions')

    # Text found in all questions
    fill_in 'keywords', :with => 'Lorem Ipsum'
    expect(page).to have_text('3 parliamentary questions out of 3.')

    # Text found in no questions
    click_button('clear-keywords-filter')
    fill_in 'keywords', :with => 'Ministry of Justice'
    expect(page).to have_text('0 parliamentary questions out of 3.')

    # Q1
    click_button('clear-keywords-filter')
    fill_in 'keywords', :with => 'not simply random text'
    expect(page).to have_text('1 parliamentary question out of 3.')

    # Q2
    click_button('clear-keywords-filter')
    fill_in 'keywords', :with => 'by Cicero, written in 45 BC'
    expect(page).to have_text('1 parliamentary question out of 3.')

    # Q3
    click_button('clear-keywords-filter')
    fill_in 'keywords', :with => 'Renaissance. The first line'
    expect(page).to have_text('1 parliamentary question out of 3.')

    click_button('clear-keywords-filter')
    expect(page).to have_text('3 parliamentary questions out of 3.')

  end

  scenario "Filter by question type 'Named Day' & keywords" do
    create_pq_session
    visit early_bird_preview_path #'/early_bird/preview'
    expect(page).to have_text('3 new parliamentary questions')

    click_button 'Question type'
    page.choose('Named Day')
    expect(page).to have_text('2 parliamentary questions out of 3.')

    # 'Named Day' + text found in all questions
    fill_in 'keywords', :with => 'Lorem Ipsum'
    expect(page).to have_text('2 parliamentary questions out of 3.')

    # 'Named Day' + text found in no questions
    click_button('clear-keywords-filter')
    fill_in 'keywords', :with => 'Ministry of Justice'
    expect(page).to have_text('0 parliamentary questions out of 3.')

    # 'Named Day' + Q1
    click_button('clear-keywords-filter')
    fill_in 'keywords', :with => 'not simply random text'
    expect(page).to have_text('1 parliamentary question out of 3.')

    # 'Named Day' + Q2
    click_button('clear-keywords-filter')
    fill_in 'keywords', :with => 'by Cicero, written in 45 BC'
    expect(page).to have_text('1 parliamentary question out of 3.')

    # 'Named Day' + Q3
    click_button('clear-keywords-filter')
    fill_in 'keywords', :with => 'Renaissance. The first line'
    expect(page).to have_text('0 parliamentary questions out of 3.')

    click_button('clear-keywords-filter')
    expect(page).to have_text('2 parliamentary questions out of 3.')
  end

  scenario "Filter by question type 'Transferred in' & keywords" do
    create_pq_session
    visit early_bird_preview_path #'/early_bird/preview'
    expect(page).to have_text('3 new parliamentary questions')

    click_button 'Question type'
    page.choose('Transferred in')

    expect(page).to have_text('1 parliamentary question out of 3.')

    # 'Transferred in' + text found in all questions
    fill_in 'keywords', :with => 'Lorem Ipsum'
    expect(page).to have_text('1 parliamentary question out of 3.')

    # 'Transferred in' + text found in no questions
    click_button('clear-keywords-filter')
    fill_in 'keywords', :with => 'Ministry of Justice'
    expect(page).to have_text('0 parliamentary questions out of 3.')

    # 'Transferred in' + Q1
    click_button('clear-keywords-filter')
    fill_in 'keywords', :with => 'not simply random text'
    expect(page).to have_text('0 parliamentary questions out of 3.')

    # 'Transferred in' + Q2
    click_button('clear-keywords-filter')
    fill_in 'keywords', :with => 'by Cicero, written in 45 BC'
    expect(page).to have_text('1 parliamentary question out of 3.')

    # 'Transferred in' + Q3
    click_button('clear-keywords-filter')
    fill_in 'keywords', :with => 'Renaissance. The first line'
    expect(page).to have_text('0 parliamentary questions out of 3.')

    click_button('clear-keywords-filter')
    expect(page).to have_text('1 parliamentary question out of 3.')

  end


  scenario "Filter by question type 'Ordinary' & keywords" do

    create_pq_session
    visit early_bird_preview_path #'/early_bird/preview'
    expect(page).to have_text('3 new parliamentary questions')

    click_button 'Question type'
    page.choose('Ordinary')
    expect(page).to have_text('1 parliamentary question out of 3.')

    # 'Ordinary' + text found in all questions
    fill_in 'keywords', :with => 'Lorem Ipsum'
    expect(page).to have_text('1 parliamentary question out of 3.')

    # 'Ordinary' + text found in no questions
    click_button('clear-keywords-filter')
    fill_in 'keywords', :with => 'Ministry of Justice'
    expect(page).to have_text('0 parliamentary questions out of 3.')

    # 'Ordinary' + Q1
    click_button('clear-keywords-filter')
    fill_in 'keywords', :with => 'not simply random text'
    expect(page).to have_text('0 parliamentary questions out of 3.')

    # 'Ordinary' + Q2
    click_button('clear-keywords-filter')
    fill_in 'keywords', :with => 'by Cicero, written in 45 BC'
    expect(page).to have_text('0 parliamentary questions out of 3.')

    # 'Ordinary' + Q3
    click_button('clear-keywords-filter')
    fill_in 'keywords', :with => 'Renaissance. The first line'
    expect(page).to have_text('1 parliamentary question out of 3.')

    click_button('clear-keywords-filter')
    expect(page).to have_text('1 parliamentary question out of 3.')

  end

  private

  def generate_dummy_pq()
    PQA::QuestionLoader.new.load_and_import(3) # Generate three questions.
  end

end
