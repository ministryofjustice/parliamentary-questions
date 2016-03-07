require 'feature_helper'

feature "User filters dashboard 'Backlog' questions", js: true, suspend_cleaner: true do

  Capybara.default_driver = :selenium

  include Features::PqHelpers

  before(:all) do

    clear_sent_mail
    DBHelpers.load_feature_fixtures
    PQA::QuestionLoader.new.load_and_import(16)
    modify_pqs

  end

  before(:each) do

    create_pq_session
    visit dashboard_path
    click_link 'Backlog'

  end

  after(:all) do

    DatabaseCleaner.clean

  end

  let(:ao1){ActionOfficer.find_by(email: 'ao1@pq.com')}

  def modify_pqs

    a = Pq.find(1)
    a.update(date_for_answer: Date.today-1)
    a.update(internal_deadline: Date.today-2)
    a.update(minister_id: 3)
    a.update(policy_minister_id: 6)
    # "With POD"

    a = Pq.find(2)
    a.update(date_for_answer: Date.today-2)
    a.update(internal_deadline: Date.today-3)
    a.update(minister_id: 3)
    a.update(policy_minister_id: 4)

    a = Pq.find(3)
    a.update(date_for_answer: Date.today-3)
    a.update(internal_deadline: Date.today-4)
    a.update(minister_id: 3)
    a.update(policy_minister_id: 4)
    a.update(question_type: 'Ordinary')
    # "With POD"

    a = Pq.find(4)
    a.update(date_for_answer: Date.today-4)
    a.update(internal_deadline: Date.today-5)
    a.update(minister_id: 5)
    a.update(policy_minister_id: 4)
    # "With POD"

    a = Pq.find(5)
    a.update(date_for_answer: Date.today-5)
    a.update(internal_deadline: Date.today-6)
    a.update(minister_id: 5)
    a.update(policy_minister_id: 4)
    a.update(question_type: 'Ordinary')

    a = Pq.find(6)
    a.update(date_for_answer: Date.today-6)
    a.update(internal_deadline: Date.today-7)
    a.update(minister_id: 3)
    a.update(policy_minister_id: 4)
    # "With POD"

    a = Pq.find(7)
    a.update(date_for_answer: Date.today-7)
    a.update(internal_deadline: Date.today-8)
    a.update(minister_id: 5)
    a.update(policy_minister_id: 6)
    a.update(question_type: 'Ordinary')
    # "With POD"

    a = Pq.find(8)
    a.update(date_for_answer: Date.today-8)
    a.update(internal_deadline: Date.today-9)
    a.update(minister_id: 3)
    a.update(policy_minister_id: 6)
    a.update(question_type: 'Ordinary')

    a = Pq.find(9)
    a.update(date_for_answer: Date.today-9)
    a.update(internal_deadline: Date.today-10)
    a.update(minister_id: 5)
    a.update(policy_minister_id: 6)
    a.update(question_type: 'Ordinary')

    a = Pq.find(10)
    a.update(date_for_answer: Date.today-10)
    a.update(internal_deadline: Date.today-11)
    a.update(minister_id: 5)
    a.update(policy_minister_id: 4)
    a.update(question_type: 'Ordinary')
    # "With POD"

    a = Pq.find(11)
    a.update(date_for_answer: Date.today-11)
    a.update(internal_deadline: Date.today-12)
    a.update(minister_id: 3)
    a.update(policy_minister_id: 6)
    a.update(question_type: 'Ordinary')
    # "With POD"

    a = Pq.find(12)
    a.update(date_for_answer: Date.today-12)
    a.update(internal_deadline: Date.today-13)
    a.update(minister_id: 5)
    a.update(policy_minister_id: 4)

    a = Pq.find(13)
    a.update(date_for_answer: Date.today-13)
    a.update(internal_deadline: Date.today-14)
    a.update(minister_id: 5)
    a.update(policy_minister_id: 6)

    a = Pq.find(14)
    a.update(date_for_answer: Date.today-14)
    a.update(internal_deadline: Date.today-15)
    a.update(minister_id: 3)
    a.update(policy_minister_id: 4)
    a.update(question_type: 'Ordinary')

    a = Pq.find(15)
    a.update(date_for_answer: Date.today-15)
    a.update(internal_deadline: Date.today-16)
    a.update(minister_id: 5)
    a.update(policy_minister_id: 6)
    # "With POD"

    a = Pq.find(16)
    a.update(date_for_answer: Date.today-16)
    a.update(internal_deadline: Date.today-17)
    a.update(minister_id: 3)
    a.update(policy_minister_id: 6)

  end

  def commission_pq(questionID)

    within ("#pq-frame-"+questionID) {
      select 'action officer 1 (Corporate Finance)', :from => 'action_officers_pqs_action_officer_id_'+questionID
      click_button 'Commission'
    }
    expect(page).to have_text('uin-'+questionID+' commissioned successfully')
    ao_mail = sent_mail.first
    visit_assignment_url(ao1)
    choose 'Accept'
    click_on "Save"
    visit dashboard_path
    click_link 'Backlog'
    clear_sent_mail

  end

  def change_status (uin, aoReturnDate)

    within ('#pq-frame-'+uin) { click_link 'uin-'+uin }
    click_link 'PQ draft'
    fill_in('Date PQ returned by action officer', :with => aoReturnDate)
    click_button 'Save'
    expect(page).to have_text('Successfully updated')
    click_link 'Backlog'

  end

  def test_date (filterBox, id, date)

    within(filterBox+".filter-box"){ fill_in id, :with => date }

  end

  def test_checkbox(filterBox, category, term)

    within("#"+filterBox+".filter-box"){
      find_button(category).trigger("click")
      choose(term)
      within(".notice") { expect(page).to have_text('1 selected') }
    }

  end

  def test_keywords(term)

    fill_in 'keywords', :with => term

  end

  def clear_filter(filterName)

    within(filterName+".filter-box") {
      click_button "Clear"
      expect(page).not_to have_text('1 selected')
    }

  end

  def commission_questions

    commission_pq('1')
    commission_pq('2')
    commission_pq('3')
    commission_pq('4')
    commission_pq('5')
    commission_pq('6')
    commission_pq('7')
    commission_pq('8')
    commission_pq('9')
    commission_pq('10')
    commission_pq('11')
    commission_pq('12')
    commission_pq('13')
    commission_pq('14')
    commission_pq('15')
    commission_pq('16')

  end

  def set_with_pod_status

    change_status('1',  Date.today-7)
    change_status('3', Date.today-9)
    change_status('4', Date.today-10)
    change_status('6', Date.today-12)
    change_status('7', Date.today-13)
    change_status('10', Date.today-16)
    change_status('11', Date.today-17)
    change_status('15', Date.today-21)

  end

  def all_pqs_visible

    within('.questions-list'){
      find('li[data-pquin="uin-16"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-1"]').visible?
    }

  end

  def all_pqs_hidden

    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

  end

  #===================================================================================
  # = Checking filter elements are present
  #===================================================================================

  scenario "1) Check filter elements are on page" do

    commission_questions
    set_with_pod_status

    within('#count'){expect(page).to have_text('16 parliamentary questions')}

    within('#filters') {
      expect(find('h2')).to have_content('Filter')
      expect(find('#date-for-answer h3')).to have_content('Date for answer')
      expect(page).to have_selector("input[type=button][id='answer-date-today']")
      expect(page).to have_selector("input[type=text][id='answer-from']")
      expect(page).to have_selector("input[type=text][id='answer-to']")
      expect(page).to have_selector("input[type=button][id='clear-answer-filter']")

      expect(find('#deadline-date h3')).to have_content('Internal deadline')
      expect(page).to have_selector("input[type=button][id='deadline-date-today']")
      expect(page).to have_selector("input[type=text][id='deadline-from']")
      expect(page).to have_selector("input[type=text][id='deadline-to']")
      expect(page).to have_selector("input[type=button][id='clear-deadline-filter']")
      expect(page).to have_button('Status')

      click_button 'Status'
      expect(page).to have_selector("input[name='flag'][type=radio][value='Draft Pending']")
      expect(page).to have_selector("input[name='flag'][type=radio][value='With POD']")
      expect(page).to have_selector("#flag input[type=button][value='Clear']")
      expect(page).to have_button('Replying minister')

      click_button 'Replying minister'
      expect(page).to have_selector("input[name='replying-minister'][type=radio][value='Jeremy Wright (MP)']")
      expect(page).to have_selector("input[name='replying-minister'][type=radio][value='Simon Hughes (MP)']")
      expect(page).to have_selector("#replying-minister input[type=button][value='Clear']")
      expect(page).to have_button('Policy minister')

      click_button 'Policy minister'
      expect(page).to have_selector("input[name='policy-minister'][type=radio][value='Lord Faulks QC']")
      expect(page).to have_selector("input[name='policy-minister'][type=radio][value='Shailesh Vara (MP)']")
      expect(page).to have_selector("#policy-minister input[type=button][value='Clear']")
      expect(page).to have_button('Question type')

      click_button 'Question type'
      expect(page).to have_selector("input[name='question-type'][type=radio][value='Named Day']")
      expect(page).to have_selector("input[name='question-type'][type=radio][value='Ordinary']")
      expect(page).to have_selector("#question-type input[type=button][value='Clear']")
      expect(page).to have_text('Keywords')
      expect(page).to have_selector("input[id='keywords'][type=text]")
      expect(page).to have_selector("input[id='clear-keywords-filter'][type=button][value='Clear']")
    }

  end

  #===================================================================================
  # = Testing individual filters
  #===================================================================================

  scenario '2) By DFA:From 20 days ago' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#date-for-answer', 'answer-from', Date.today-20)
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

    clear_filter('#date-for-answer')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '3) By DFA:From 8 days ago' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#date-for-answer', 'answer-from', Date.today-8)
    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        find('li[data-pquin="uin-8"]').visible?
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        find('li[data-pquin="uin-5"]').visible?
        find('li[data-pquin="uin-4"]').visible?
        find('li[data-pquin="uin-3"]').visible?
        find('li[data-pquin="uin-2"]').visible?
        find('li[data-pquin="uin-1"]').visible?
    }

    clear_filter('#date-for-answer')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '4) By DFA:From 20 days from now' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#date-for-answer', 'answer-from', Date.today+20)
    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    all_pqs_hidden

    clear_filter('#date-for-answer')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '5) By DFA:To 20 days ago' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#date-for-answer', 'answer-to', Date.today-20)
    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    all_pqs_hidden

    clear_filter('#date-for-answer')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '6) By DFA:To 8 days ago' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#date-for-answer', 'answer-to', Date.today-8)
    within('#count'){expect(page).to have_text('9 parliamentary questions out of 16.')}
    within('.questions-list'){
        find('li[data-pquin="uin-16"]').visible?
        find('li[data-pquin="uin-15"]').visible?
        find('li[data-pquin="uin-14"]').visible?
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    clear_filter('#date-for-answer')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '7) By DFA:To 20 days from now' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#date-for-answer', 'answer-to', Date.today+20)
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

    clear_filter('#date-for-answer')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '8) By ID:From 20 days ago' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#deadline-date', 'deadline-from', Date.today-20)
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

    clear_filter('#deadline-date')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '9) By ID:From 7 days ago' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#deadline-date', 'deadline-from', Date.today-7)
    within('#count'){expect(page).to have_text('6 parliamentary questions out of 16')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        find('li[data-pquin="uin-6"]').visible?
        find('li[data-pquin="uin-5"]').visible?
        find('li[data-pquin="uin-4"]').visible?
        find('li[data-pquin="uin-3"]').visible?
        find('li[data-pquin="uin-2"]').visible?
        find('li[data-pquin="uin-1"]').visible?
    }

    clear_filter('#deadline-date')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '10) By ID:From 20 days from now' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#deadline-date', 'deadline-from', Date.today+20)
    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    all_pqs_hidden

    clear_filter('#deadline-date')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '11) By ID:To 20 days ago' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#deadline-date', 'deadline-to', Date.today-20)
    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    all_pqs_hidden

    clear_filter('#deadline-date')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '12) By ID:To 7 days ago' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#deadline-date', 'deadline-to', Date.today-7)
    within('#count'){expect(page).to have_text('11 parliamentary questions out of 16.')}
    within('.questions-list'){
        find('li[data-pquin="uin-16"]').visible?
        find('li[data-pquin="uin-15"]').visible?
        find('li[data-pquin="uin-14"]').visible?
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    clear_filter('#deadline-date')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '13) By ID:To 10 days from now' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#deadline-date', 'deadline-to', Date.today+10)
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

    clear_filter('#deadline-date')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '14) By Status "With POD"' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_checkbox('flag', 'Status', 'With POD')
    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
      find('li[data-pquin="uin-15"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      find('li[data-pquin="uin-1"]').visible?
    }

    clear_filter('#flag')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '15) By Replying minister "Jeremy Wright (MP)"' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_checkbox('replying-minister', 'Replying minister', 'Jeremy Wright (MP)')
    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    within('.questions-list'){
        find('li[data-pquin="uin-16"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        find('li[data-pquin="uin-14"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        find('li[data-pquin="uin-11"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        find('li[data-pquin="uin-8"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        find('li[data-pquin="uin-6"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        find('li[data-pquin="uin-3"]').visible?
        find('li[data-pquin="uin-2"]').visible?
        find('li[data-pquin="uin-1"]').visible?
    }

    clear_filter('#replying-minister')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '16) By Policy minister "Lord Faulks QC"' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_checkbox('policy-minister', 'Policy minister', 'Lord Faulks QC')
    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    within('.questions-list'){
        find('li[data-pquin="uin-16"]').visible?
        find('li[data-pquin="uin-15"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        find('li[data-pquin="uin-13"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        find('li[data-pquin="uin-11"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        find('li[data-pquin="uin-7"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        find('li[data-pquin="uin-1"]').visible?
    }

    clear_filter('#policy-minister')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '17) By Question Type "Ordinary"' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_checkbox('question-type', 'Question type', 'Ordinary')
    within('#count') { expect(page).to have_text('8 parliamentary questions out of 16.') }
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        find('li[data-pquin="uin-14"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        find('li[data-pquin="uin-7"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        find('li[data-pquin="uin-5"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        find('li[data-pquin="uin-3"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    clear_filter('#question-type')
    within('#count') { expect(page).to have_text('16 parliamentary questions out of 16.') }
    all_pqs_visible

  end

  scenario '18) By Keyword "Mock"' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_keywords('Mock')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

    test_keywords('')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '19) By Keyword "uin-1"' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_keywords('uin-1')
    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-16"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      find('li[data-pquin="uin-1"]').visible?
    }

    test_keywords('')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '20) By Keyword "Ministry of Justice"' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_keywords('Ministry of Justice')
    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    all_pqs_hidden

    test_keywords('')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  #===================================================================================
  # = Testing filter combinations
  #===================================================================================

  scenario '21) By date for answer between 20 days ago & 10 days from now' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#date-for-answer', 'answer-from', Date.today-20)
    test_date('#date-for-answer', 'answer-to', Date.today+10)
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

    clear_filter('#date-for-answer')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '22) By date for answer between 3 & 4 days ago' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#date-for-answer', 'answer-from', Date.today-4)
    test_date('#date-for-answer', 'answer-to', Date.today-3)
    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    clear_filter('#date-for-answer')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '23) By date for answer between 10 & 15 days from now' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#date-for-answer', 'answer-from', Date.today+10)
    test_date('#date-for-answer', 'answer-to', Date.today+15)
    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    all_pqs_hidden

    clear_filter('#date-for-answer')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '24) By Internal Deadline between 20 & 25 days ago' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#deadline-date', 'deadline-from', Date.today-20)
    test_date('#deadline-date', 'deadline-to', Date.today-25)
    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    all_pqs_hidden

    clear_filter('#deadline-date')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '25) By Internal Deadline between 4 & 5 days ago' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#deadline-date', 'deadline-from', Date.today-5)
    test_date('#deadline-date', 'deadline-to', Date.today-4)
    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    clear_filter('#deadline-date')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '26) By Internal Deadline between 10 & 15 days from now' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#deadline-date', 'deadline-from', Date.today+10)
    test_date('#deadline-date', 'deadline-to', Date.today+15)
    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    all_pqs_hidden

    clear_filter('#deadline-date')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '27) By Replying Minister, Policy Minister' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_checkbox('replying-minister', 'Replying minister', 'Jeremy Wright (MP)')
    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    within('.questions-list'){
        find('li[data-pquin="uin-16"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        find('li[data-pquin="uin-14"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        find('li[data-pquin="uin-11"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        find('li[data-pquin="uin-8"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        find('li[data-pquin="uin-6"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        find('li[data-pquin="uin-3"]').visible?
        find('li[data-pquin="uin-2"]').visible?
        find('li[data-pquin="uin-1"]').visible?
    }

    test_checkbox('policy-minister', 'Policy minister', 'Lord Faulks QC')
    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}
    within('.questions-list'){
        find('li[data-pquin="uin-16"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        find('li[data-pquin="uin-11"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        find('li[data-pquin="uin-8"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        find('li[data-pquin="uin-1"]').visible?
    }

    clear_filter('#policy-minister')
    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-16"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      find('li[data-pquin="uin-14"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      find('li[data-pquin="uin-11"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      find('li[data-pquin="uin-8"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      find('li[data-pquin="uin-6"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-1"]').visible?
    }

    clear_filter('#replying-minister')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '28) By DFA:To, ID:From, Replying Minister' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#date-for-answer', 'answer-to', Date.today-6)
    within('#count'){expect(page).to have_text('11 parliamentary questions out of 16.')}
    within('.questions-list'){
        find('li[data-pquin="uin-16"]').visible?
        find('li[data-pquin="uin-15"]').visible?
        find('li[data-pquin="uin-14"]').visible?
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_date('#deadline-date', 'deadline-from', Date.today-12)
    within('#count'){expect(page).to have_text('6 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_checkbox('replying-minister', 'Replying minister', 'Simon Hughes (MP)')
    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        find('li[data-pquin="uin-7"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    clear_filter('#replying-minister')
    within('#count'){expect(page).to have_text('6 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    within('#filters #deadline-date.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('11 parliamentary questions out of 16.')}
    within('.questions-list'){
        find('li[data-pquin="uin-16"]').visible?
        find('li[data-pquin="uin-15"]').visible?
        find('li[data-pquin="uin-14"]').visible?
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    within('#filters #date-for-answer.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '29) By DFA:From, ID:To, Replying Minister, Question type' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#date-for-answer', 'answer-from', Date.today-4)
    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        find('li[data-pquin="uin-4"]').visible?
        find('li[data-pquin="uin-3"]').visible?
        find('li[data-pquin="uin-2"]').visible?
        find('li[data-pquin="uin-1"]').visible?
    }

    test_date('#deadline-date', 'deadline-to', Date.today-3)
    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        find('li[data-pquin="uin-4"]').visible?
        find('li[data-pquin="uin-3"]').visible?
        find('li[data-pquin="uin-2"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_checkbox('replying-minister', 'Replying minister', 'Jeremy Wright (MP)')
    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        find('li[data-pquin="uin-3"]').visible?
        find('li[data-pquin="uin-2"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_checkbox('question-type', 'Question type', 'Ordinary')
    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        find('li[data-pquin="uin-3"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    clear_filter('#question-type')
    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        find('li[data-pquin="uin-3"]').visible?
        find('li[data-pquin="uin-2"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    clear_filter('#replying-minister')
    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        find('li[data-pquin="uin-4"]').visible?
        find('li[data-pquin="uin-3"]').visible?
        find('li[data-pquin="uin-2"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    within('#filters #deadline-date.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        find('li[data-pquin="uin-4"]').visible?
        find('li[data-pquin="uin-3"]').visible?
        find('li[data-pquin="uin-2"]').visible?
        find('li[data-pquin="uin-1"]').visible?
    }

    within('#filters #date-for-answer.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '30) By DFA:From, DFA:To, ID:From, ID:To, Keyword' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#date-for-answer', 'answer-from', Date.today-20)
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

    test_date('#date-for-answer', 'answer-to', Date.today-9)
    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    within('.questions-list'){
        find('li[data-pquin="uin-16"]').visible?
        find('li[data-pquin="uin-15"]').visible?
        find('li[data-pquin="uin-14"]').visible?
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_date('#deadline-date', 'deadline-from', Date.today-16)
    within('#count'){expect(page).to have_text('7 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        find('li[data-pquin="uin-15"]').visible?
        find('li[data-pquin="uin-14"]').visible?
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_date('#deadline-date', 'deadline-to', Date.today-12)
    within('#count'){expect(page).to have_text('5 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        find('li[data-pquin="uin-15"]').visible?
        find('li[data-pquin="uin-14"]').visible?
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_keywords('uin-14')
    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        find('li[data-pquin="uin-14"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    within('#filters'){find_button("clear-keywords-filter").trigger("click")}
    within('#count'){expect(page).to have_text('5 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        find('li[data-pquin="uin-15"]').visible?
        find('li[data-pquin="uin-14"]').visible?
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    within('#deadline-date.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    within('.questions-list'){
        find('li[data-pquin="uin-16"]').visible?
        find('li[data-pquin="uin-15"]').visible?
        find('li[data-pquin="uin-14"]').visible?
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    within('#date-for-answer.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '31) By DFA:From, DFA:To, ID:To, Status, Replying Minister, Policy Minister' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#date-for-answer', 'answer-from', Date.today-7)
    within('#count'){expect(page).to have_text('7 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        find('li[data-pquin="uin-5"]').visible?
        find('li[data-pquin="uin-4"]').visible?
        find('li[data-pquin="uin-3"]').visible?
        find('li[data-pquin="uin-2"]').visible?
        find('li[data-pquin="uin-1"]').visible?
    }

    test_date('#date-for-answer', 'answer-to', Date.today-3)
    within('#count'){expect(page).to have_text('5 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        find('li[data-pquin="uin-5"]').visible?
        find('li[data-pquin="uin-4"]').visible?
        find('li[data-pquin="uin-3"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_date('#deadline-date', 'deadline-to', Date.today-5)
    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        find('li[data-pquin="uin-5"]').visible?
        find('li[data-pquin="uin-4"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_checkbox('flag', 'Status', 'With POD')
    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        find('li[data-pquin="uin-4"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_checkbox('replying-minister', 'Replying minister', 'Simon Hughes (MP)')
    within('#count'){expect(page).to have_text('2  parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        find('li[data-pquin="uin-7"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        find('li[data-pquin="uin-4"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_checkbox('policy-minister', 'Policy minister', 'Shailesh Vara (MP)')
    within('#count'){expect(page).to have_text('1  parliamentary question out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        find('li[data-pquin="uin-4"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    clear_filter('#policy-minister')
    within('#count'){expect(page).to have_text('2  parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        find('li[data-pquin="uin-7"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        find('li[data-pquin="uin-4"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    clear_filter('#replying-minister')
    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        find('li[data-pquin="uin-4"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    clear_filter('#flag')
    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        find('li[data-pquin="uin-5"]').visible?
        find('li[data-pquin="uin-4"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    within('#deadline-date.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('5 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        find('li[data-pquin="uin-5"]').visible?
        find('li[data-pquin="uin-4"]').visible?
        find('li[data-pquin="uin-3"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    within('#date-for-answer.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '32) By DFA:From, DFA:To, ID:From, ID:To, Status, Question type, Keyword' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#date-for-answer', 'answer-from', Date.today-20)
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

    test_date('#date-for-answer', 'answer-to', Date.today-5)
    within('#count'){expect(page).to have_text('12 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-16"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_date('#deadline-date', 'deadline-from', Date.today-16)
    within('#count'){expect(page).to have_text('11 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_date('#deadline-date', 'deadline-to', Date.today-9)
    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        find('li[data-pquin="uin-15"]').visible?
        find('li[data-pquin="uin-14"]').visible?
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_checkbox('flag', 'Status', 'Draft Pending')
    within('#count'){expect(page).to have_text('5 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        find('li[data-pquin="uin-14"]').visible?
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_checkbox('question-type', 'Question type', 'Named Day')
    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_keywords('uin-13')
    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        find('li[data-pquin="uin-13"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    within('#filters'){find_button("clear-keywords-filter").trigger("click")}
    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    clear_filter('#question-type')
    within('#count'){expect(page).to have_text('5 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        find('li[data-pquin="uin-14"]').visible?
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    clear_filter('#flag')
    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        find('li[data-pquin="uin-15"]').visible?
        find('li[data-pquin="uin-14"]').visible?
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    within('#deadline-date.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('12 parliamentary questions out of 16.')}
    within('.questions-list'){
        find('li[data-pquin="uin-16"]').visible?
        find('li[data-pquin="uin-15"]').visible?
        find('li[data-pquin="uin-14"]').visible?
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        find('li[data-pquin="uin-5"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    within('#date-for-answer.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '33) By DFA:From, DFA:To, ID:From, Status, Replying Minister, Policy Minister, Question type, Keyword' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#date-for-answer', 'answer-from', Date.today-14)
    within('#count'){expect(page).to have_text('14 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        find('li[data-pquin="uin-14"]').visible?
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        find('li[data-pquin="uin-5"]').visible?
        find('li[data-pquin="uin-4"]').visible?
        find('li[data-pquin="uin-3"]').visible?
        find('li[data-pquin="uin-2"]').visible?
        find('li[data-pquin="uin-1"]').visible?
    }

    test_date('#date-for-answer', 'answer-to', Date.today-3)
    within('#count'){expect(page).to have_text('12 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        find('li[data-pquin="uin-14"]').visible?
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        find('li[data-pquin="uin-5"]').visible?
        find('li[data-pquin="uin-4"]').visible?
        find('li[data-pquin="uin-3"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_date('#deadline-date', 'deadline-from', Date.today-13)
    within('#count'){expect(page).to have_text('10 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        find('li[data-pquin="uin-5"]').visible?
        find('li[data-pquin="uin-4"]').visible?
        find('li[data-pquin="uin-3"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_checkbox('flag', 'Status', 'With POD')
    within('#count'){expect(page).to have_text('6 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        find('li[data-pquin="uin-4"]').visible?
        find('li[data-pquin="uin-3"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_checkbox('replying-minister', 'Replying minister', 'Simon Hughes (MP)')
    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        find('li[data-pquin="uin-10"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        find('li[data-pquin="uin-7"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        find('li[data-pquin="uin-4"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_checkbox('policy-minister', 'Policy minister', 'Shailesh Vara (MP)')
    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        find('li[data-pquin="uin-10"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        find('li[data-pquin="uin-4"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_checkbox('question-type', 'Question type', 'Named Day')
    within('#count'){expect(page).to have_text('1 parliamentary question  out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        find('li[data-pquin="uin-4"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_keywords('uin-4')
    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        find('li[data-pquin="uin-4"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    within('#filters'){find_button("clear-keywords-filter").trigger("click")}
    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        find('li[data-pquin="uin-4"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    clear_filter('#question-type')
    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        find('li[data-pquin="uin-10"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        find('li[data-pquin="uin-4"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    clear_filter('#policy-minister')
    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        find('li[data-pquin="uin-10"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        find('li[data-pquin="uin-7"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        find('li[data-pquin="uin-4"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    clear_filter('#replying-minister')
    within('#count'){expect(page).to have_text('6 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-9"]')
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        find('li[data-pquin="uin-4"]').visible?
        find('li[data-pquin="uin-3"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    clear_filter('#flag')
    within('#count'){expect(page).to have_text('10 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        find('li[data-pquin="uin-5"]').visible?
        find('li[data-pquin="uin-4"]').visible?
        find('li[data-pquin="uin-3"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    within('#deadline-date.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('12 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        find('li[data-pquin="uin-14"]').visible?
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        find('li[data-pquin="uin-5"]').visible?
        find('li[data-pquin="uin-4"]').visible?
        find('li[data-pquin="uin-3"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    within('#date-for-answer.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

  scenario '34) By DFA:From, DFA:To, ID:From, ID:To, Status, Replying Minister, Policy Minister, Question type, Keyword' do

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#date-for-answer', 'answer-from', Date.today-15)
    within('#count'){expect(page).to have_text('15 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        find('li[data-pquin="uin-15"]').visible?
        find('li[data-pquin="uin-14"]').visible?
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        find('li[data-pquin="uin-5"]').visible?
        find('li[data-pquin="uin-4"]').visible?
        find('li[data-pquin="uin-3"]').visible?
        find('li[data-pquin="uin-2"]').visible?
        find('li[data-pquin="uin-1"]').visible?
    }

    test_date('#date-for-answer', 'answer-to', Date.today-3)
    within('#count'){expect(page).to have_text('13 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        find('li[data-pquin="uin-15"]').visible?
        find('li[data-pquin="uin-14"]').visible?
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        find('li[data-pquin="uin-5"]').visible?
        find('li[data-pquin="uin-4"]').visible?
        find('li[data-pquin="uin-3"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_date('#deadline-date', 'deadline-from', Date.today-14)
    within('#count'){expect(page).to have_text('11 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        find('li[data-pquin="uin-5"]').visible?
        find('li[data-pquin="uin-4"]').visible?
        find('li[data-pquin="uin-3"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_date('#deadline-date', 'deadline-to', Date.today-6)
    within('#count'){expect(page).to have_text('9 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        find('li[data-pquin="uin-5"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_checkbox('flag', 'Status', 'Draft Pending')
    within('#count'){expect(page).to have_text('5 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        find('li[data-pquin="uin-5"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_checkbox('replying-minister', 'Replying minister', 'Simon Hughes (MP)')
    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        find('li[data-pquin="uin-9"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        find('li[data-pquin="uin-5"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_checkbox('policy-minister', 'Policy minister', 'Lord Faulks QC')
    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        find('li[data-pquin="uin-13"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        find('li[data-pquin="uin-9"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_checkbox('question-type', 'Question type', 'Ordinary')
    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        find('li[data-pquin="uin-9"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    test_keywords('uin-9')
    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        find('li[data-pquin="uin-9"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    within('#filters'){find_button("clear-keywords-filter").trigger("click")}
    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        expect(page).not_to have_selector('li[data-pquin="uin-13"]')
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        find('li[data-pquin="uin-9"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    clear_filter('#question-type')
    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        find('li[data-pquin="uin-13"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-12"]')
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        find('li[data-pquin="uin-9"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        expect(page).not_to have_selector('li[data-pquin="uin-5"]')
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    clear_filter('#policy-minister')
    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        find('li[data-pquin="uin-9"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-8"]')
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        find('li[data-pquin="uin-5"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    clear_filter('#replying-minister')
    within('#count'){expect(page).to have_text('5 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-11"]')
        expect(page).not_to have_selector('li[data-pquin="uin-10"]')
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-7"]')
        expect(page).not_to have_selector('li[data-pquin="uin-6"]')
        find('li[data-pquin="uin-5"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    clear_filter('#flag')
    within('#count'){expect(page).to have_text('9 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        expect(page).not_to have_selector('li[data-pquin="uin-15"]')
        expect(page).not_to have_selector('li[data-pquin="uin-14"]')
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        find('li[data-pquin="uin-5"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-4"]')
        expect(page).not_to have_selector('li[data-pquin="uin-3"]')
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    within('#deadline-date.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('13 parliamentary questions out of 16.')}
    within('.questions-list'){
        expect(page).not_to have_selector('li[data-pquin="uin-16"]')
        find('li[data-pquin="uin-15"]').visible?
        find('li[data-pquin="uin-14"]').visible?
        find('li[data-pquin="uin-13"]').visible?
        find('li[data-pquin="uin-12"]').visible?
        find('li[data-pquin="uin-11"]').visible?
        find('li[data-pquin="uin-10"]').visible?
        find('li[data-pquin="uin-9"]').visible?
        find('li[data-pquin="uin-8"]').visible?
        find('li[data-pquin="uin-7"]').visible?
        find('li[data-pquin="uin-6"]').visible?
        find('li[data-pquin="uin-5"]').visible?
        find('li[data-pquin="uin-4"]').visible?
        find('li[data-pquin="uin-3"]').visible?
        expect(page).not_to have_selector('li[data-pquin="uin-2"]')
        expect(page).not_to have_selector('li[data-pquin="uin-1"]')
    }

    within('#date-for-answer.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

  end

end
