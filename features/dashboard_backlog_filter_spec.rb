require 'feature_helper'

feature "User filters 'Backlog' dashboard  questions", js: true, suspend_cleaner: true do

  include Features::PqHelpers

=begin
    clear_sent_mail
    DBHelpers.load_feature_fixtures
    PQA::QuestionLoader.new.load_and_import(16)
    modify_pqs
    create_pq_session
    visit dashboard_path
    click_link 'Backlog'
    commission_questions
    set_with_pod_status
=end

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
    a.update(date_for_answer: '29/11/2015')
    a.update(internal_deadline: '27/11/2015 11:00')
    a.update(minister_id: 3)
    a.update(policy_minister_id: 6)
    # "With POD"

    a = Pq.find(2)
    a.update(date_for_answer: '28/11/2015')
    a.update(internal_deadline: '26/11/2015 11:00')
    a.update(minister_id: 3)
    a.update(policy_minister_id: 4)

    a = Pq.find(3)
    a.update(date_for_answer: '27/11/2015')
    a.update(internal_deadline: '25/11/2015 11:00')
    a.update(minister_id: 3)
    a.update(policy_minister_id: 4)
    a.update(question_type: 'Ordinary')
    # "With POD"

    a = Pq.find(4)
    a.update(date_for_answer: '26/11/2015')
    a.update(internal_deadline: '24/11/2015 11:00')
    a.update(minister_id: 5)
    a.update(policy_minister_id: 4)
    # "With POD"

    a = Pq.find(5)
    a.update(date_for_answer: '25/11/2015')
    a.update(internal_deadline: '23/11/2015 11:00')
    a.update(minister_id: 5)
    a.update(policy_minister_id: 4)
    a.update(question_type: 'Ordinary')

    a = Pq.find(6)
    a.update(date_for_answer: '24/11/2015')
    a.update(internal_deadline: '22/11/2015 11:00')
    a.update(minister_id: 3)
    a.update(policy_minister_id: 4)
    # "With POD"

    a = Pq.find(7)
    a.update(date_for_answer: '23/11/2015')
    a.update(internal_deadline: '21/11/2015 11:00')
    a.update(minister_id: 5)
    a.update(policy_minister_id: 6)
    a.update(question_type: 'Ordinary')
    # "With POD"

    a = Pq.find(8)
    a.update(date_for_answer: '22/11/2015')
    a.update(internal_deadline: '20/11/2015 11:00')
    a.update(minister_id: 3)
    a.update(policy_minister_id: 6)
    a.update(question_type: 'Ordinary')

    a = Pq.find(9)
    a.update(date_for_answer: '21/11/2015')
    a.update(internal_deadline: '19/11/2015 11:00')
    a.update(minister_id: 5)
    a.update(policy_minister_id: 6)
    a.update(question_type: 'Ordinary')

    a = Pq.find(10)
    a.update(date_for_answer: '20/11/2015')
    a.update(internal_deadline: '18/11/2015 11:00')
    a.update(minister_id: 5)
    a.update(policy_minister_id: 4)
    a.update(question_type: 'Ordinary')
    # "With POD"

    a = Pq.find(11)
    a.update(date_for_answer: '19/11/2015')
    a.update(internal_deadline: '17/11/2015 11:00')
    a.update(minister_id: 3)
    a.update(policy_minister_id: 6)
    a.update(question_type: 'Ordinary')
    # "With POD"

    a = Pq.find(12)
    a.update(date_for_answer: '18/11/2015')
    a.update(internal_deadline: '16/11/2015 11:00')
    a.update(minister_id: 5)
    a.update(policy_minister_id: 4)

    a = Pq.find(13)
    a.update(date_for_answer: '17/11/2015')
    a.update(internal_deadline: '15/11/2015 11:00')
    a.update(minister_id: 5)
    a.update(policy_minister_id: 6)

    a = Pq.find(14)
    a.update(date_for_answer: '16/11/2015')
    a.update(internal_deadline: '14/11/2015 11:00')
    a.update(minister_id: 3)
    a.update(policy_minister_id: 4)
    a.update(question_type: 'Ordinary')

    a = Pq.find(15)
    a.update(date_for_answer: '15/11/2015')
    a.update(internal_deadline: '13/11/2015 11:00')
    a.update(minister_id: 5)
    a.update(policy_minister_id: 6)
    # "With POD"

    a = Pq.find(16)
    a.update(date_for_answer: '14/11/2015')
    a.update(internal_deadline: '12/11/2015 11:00')
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
    within("#"+filterBox+".filter-box") { fill_in id, :with => date }
  end

  def test_checkbox(filterBox, category, term)
    within("#"+filterBox+".filter-box") {
      click_button category
      choose term
      within(".notice"){expect(page).to have_text('1 selected')}
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
    change_status('1', '22/11/2015 11:00')
    change_status('3', '20/11/2015 11:00')
    change_status('4', '19/11/2015 11:00')
    change_status('6', '17/11/2015 11:00')
    change_status('7', '16/11/2015 11:00')
    change_status('10', '13/11/2015 11:00')
    change_status('11', '12/11/2015 11:00')
    change_status('15', '08/11/2015 11:00')
  end

  #===================================================================================
  # = Checking filter elements are present
  #===================================================================================

  scenario "Check filter elements are on page" do

    puts "\n.1) Check filter elements are on page"

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


  scenario 'PQs filtered by date for answer from 01/10/2015.' do

    puts "2) PQs filtered by date for answer from 01/10/2015."

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('date-for-answer', 'answer-from', '01/10/2015')
    
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    clear_filter('#date-for-answer')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

  end

  scenario 'PQs filtered by date for answer from 22/11/2015.' do

    puts "3) PQs filtered by date for answer from 22/11/2015."

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('date-for-answer', 'answer-from', '22/11/2015')

    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#date-for-answer')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

  end

  scenario 'PQs filtered by date for answer from 01/12/2015.' do

    puts "4) PQs filtered by date for answer from 01/12/2015."

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('date-for-answer', 'answer-from', '01/12/2015')

    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#date-for-answer')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

  end

  scenario 'PQs filtered by date for answer to 01/10/2015.' do

    puts "5) PQs filtered by date for answer to 01/10/2015."

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('date-for-answer', 'answer-to', '01/10/2015')

    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#date-for-answer')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

  end

  scenario 'PQs filtered by date for answer to 22/11/2015.' do

    puts "6) PQs filtered by date for answer to 22/11/2015."

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('date-for-answer', 'answer-to', '22/11/2015')

    within('#count'){expect(page).to have_text('9 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    clear_filter('#date-for-answer')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

  end

  scenario 'PQs filtered by date for answer to 01/12/2015.' do

    puts "7) PQs filtered by date for answer to 01/12/2015."

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('date-for-answer', 'answer-to', '01/12/2015')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    clear_filter('#date-for-answer')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

  end

  scenario 'PQs filtered by internal deadline from 01/10/2015.' do

    puts "8) PQs filtered by internal deadline from 01/10/2015."

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('deadline-date', 'deadline-from', '01/10/2015')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    clear_filter('#deadline-date')
    
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

  end

  scenario 'PQs filtered by internal deadline from 22/11/2015.' do

    puts "9) PQs filtered by internal deadline from 22/11/2015."

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('deadline-date', 'deadline-from', '22/11/2015')

    within('#count'){expect(page).to have_text('6 parliamentary questions out of 16')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin=14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#deadline-date')
    
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

  end

  scenario 'PQs filtered by internal deadline from 01/12/2015.' do

    puts "10) PQs filtered by internal deadline from 01/12/2015."

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('deadline-date', 'deadline-from', '01/12/2015')

    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin=14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#deadline-date')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

  end

  scenario 'PQs filtered by internal deadline to 01/10/2015.' do

    puts "11) PQs filtered by internal deadline to 01/12/2015."

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
    
    test_date('deadline-date', 'deadline-to', '01/10/2015')

    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin=14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }
    
    clear_filter('#deadline-date')
    
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
  end

  scenario 'PQs filtered by internal deadline to 22/11/2015.' do

    puts "12) PQs filtered by internal deadline to 22/11/2015."

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
    
    test_date('deadline-date', 'deadline-to', '22/11/2015')
    
    within('#count'){expect(page).to have_text('11 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
    
    clear_filter('#deadline-date')
    
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
  end

  scenario 'PQs filtered by internal deadline to 01/12/2015.' do

    puts "13) PQs filtered by internal deadline to 01/12/2015."

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('deadline-date', 'deadline-to', '01/12/2015')
    
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
    
    clear_filter('#deadline-date')
    
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
  end

  scenario 'PQs filtered by Status.' do

    puts "14) PQs filtered by Status."

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_checkbox('flag', 'Status', 'With POD')

    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      find('li[data-pquin="uin-15"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#flag')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
  end

  scenario 'PQs filtered by Replying minister Jeremy Wright (MP).' do

    puts "15) PQs filtered by Replying minister Jeremy Wright (MP)."

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_checkbox('replying-minister', 'Replying minister', 'Jeremy Wright (MP)')
    
    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      find('li[data-pquin="uin-6"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      find('li[data-pquin="uin-8"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      find('li[data-pquin="uin-11"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      find('li[data-pquin="uin-14"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      find('li[data-pquin="uin-16"]').visible?
    }

    clear_filter('#replying-minister')
    
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
  end

  scenario 'PQs filtered by Policy minister Lord Faulks QC.' do

    puts "16) PQs filtered by Policy minister Lord Faulks QC."

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_checkbox('policy-minister', 'Policy minister', 'Lord Faulks QC')

    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      find('li[data-pquin="uin-11"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      find('li[data-pquin="uin-13"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    clear_filter('#policy-minister')
    
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
  end

  scenario "PQs filtered by Question Type 'Ordinary'." do

    puts "17) PQs filtered by Question Type 'Ordinary'."

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_checkbox('question-type', 'Question type', 'Ordinary')

    within('#count') { expect(page).to have_text('8 parliamentary questions out of 16.') }
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      find('li[data-pquin="uin-3"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      find('li[data-pquin="uin-5"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      find('li[data-pquin="uin-14"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#question-type')
    
    within('#count') { expect(page).to have_text('16 parliamentary questions out of 16.') }
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

  end

  scenario "PQs filtered by Keyword 'Mock'." do

    puts "18) PQs filtered by Question Type 'Mock'."

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_keywords('Mock')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_keywords('')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
  end

  scenario "PQs filtered by Keyword 'uin-1'." do

    puts "19) PQs filtered by Question Type 'uin-1'."

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_keywords('uin-1')

    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_keywords('')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
  end

  scenario "PQs filtered by Keyword 'Ministry of Justice'." do

    puts "20) PQs filtered by Question Type 'Ministry of Justice'."

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_keywords('Ministry of Justice')

    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_keywords('')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
  end


  #===================================================================================
  # = Testing filter combinations
  #===================================================================================

  scenario "PQs filtered by date for answer 01/10/2015 - 01/12/2015" do

    puts "21) PQs filtered by date for answer 01/10/2015 - 01/12/2015"

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('date-for-answer', 'answer-from', '01/10/2015')
    test_date('date-for-answer', 'answer-to', '01/12/2015')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    clear_filter('#date-for-answer')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
  end

  scenario "PQs filtered by date for answer 26/11/2015 - 27/11/2015" do

    puts "22) PQs filtered by date for answer 26/11/2015 - 27/11/2015"

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('date-for-answer', 'answer-from', '26/11/2015')
    test_date('date-for-answer', 'answer-to', '27/11/2015')

    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#date-for-answer')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
  end

  scenario "PQs filtered by date for answer 01/12/2015 - 15/12/2015" do

    puts "23) PQs filtered by date for answer 01/12/2015 - 15/12/2015"

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('date-for-answer', 'answer-from', '01/12/2015')
    test_date('date-for-answer', 'answer-to', '05/12/2015')

    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#date-for-answer')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
  end

  scenario "A user filters the PQ list by: Internal Deadline 01/10/2015 - 20/10/2015" do

    puts "24) PQs filtered by internal deadline 01/10/2015 - 20/10/2015"

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('deadline-date', 'deadline-from', '01/10/2015')
    test_date('deadline-date', 'deadline-to', '20/10/2015')

    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }
    
    clear_filter('#deadline-date')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

  end

  scenario "A user filters the PQ list by: Internal Deadline 24/11/2015 - 25/11/2015" do

    puts "25) PQs filtered by internal deadline 24/11/2015 - 25/11/2015"

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('deadline-date', 'deadline-from', '24/11/2015')
    test_date('deadline-date', 'deadline-to', '25/11/2015')

    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#deadline-date')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
  end

  scenario "A user filters the PQ list by: Internal Deadline 01/12/2015 - 15/12/2015" do

    puts "26) PQs filtered by internal deadline 01/12/2015 - 15/12/2015"

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('deadline-date', 'deadline-from', '01/12/2015')
    test_date('deadline-date', 'deadline-to', '15/12/2015')

    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#deadline-date')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

  end

  scenario 'PQs filtered by Replying Minister, Policy Minister' do

    puts "27) PQs filtered by Replying Minister, Policy Minister"

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_checkbox('replying-minister', 'Replying minister', 'Jeremy Wright (MP)')

    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      find('li[data-pquin="uin-6"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      find('li[data-pquin="uin-8"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      find('li[data-pquin="uin-11"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      find('li[data-pquin="uin-14"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      find('li[data-pquin="uin-16"]').visible?
    }

    test_checkbox('policy-minister', 'Policy minister', 'Lord Faulks QC')

    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      find('li[data-pquin="uin-8"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      find('li[data-pquin="uin-11"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      find('li[data-pquin="uin-16"]').visible?
    }

    clear_filter('#policy-minister')

    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      find('li[data-pquin="uin-6"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      find('li[data-pquin="uin-8"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      find('li[data-pquin="uin-11"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      find('li[data-pquin="uin-14"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      find('li[data-pquin="uin-16"]').visible?
    }

    clear_filter('#replying-minister')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
  end

  scenario 'PQs filtered by DFA:To, ID:From, Replying Minister' do

    puts "28) PQs filtered by DFA:To, ID:From, Replying Minister"

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('date-for-answer', 'answer-to', '24/11/2015')

    within('#count'){expect(page).to have_text('11 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('deadline-date', 'deadline-from', '17/11/2015')

    within('#count'){expect(page).to have_text('6 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_checkbox('replying-minister', 'Replying minister', 'Simon Hughes (MP)')

    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      find('li[data-pquin="uin-7"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#replying-minister')

    within('#count'){expect(page).to have_text('6 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    within('#filters #deadline-date.filter-box'){find_button("Clear").trigger("click")}

    within('#count'){expect(page).to have_text('11 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    within('#filters #date-for-answer.filter-box'){find_button("Clear").trigger("click")}

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
  end

  scenario 'PQs filtered by DFA:From, ID:To, Replying Minister, Question type' do

    puts "29) PQs filtered by DFA:From, ID:To, Replying Minister, Question type"

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('date-for-answer', 'answer-from', '26/11/2015')

    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_date('deadline-date', 'deadline-to', '26/11/2015')

    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_checkbox('replying-minister', 'Replying minister', 'Jeremy Wright (MP)')

    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_checkbox('question-type', 'Question type', 'Ordinary')

    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      find('li[data-pquin="uin-3"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#question-type')

    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#replying-minister')

    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    within('#filters #deadline-date.filter-box'){find_button("Clear").trigger("click")}

    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    within('#filters #date-for-answer.filter-box'){find_button("Clear").trigger("click")}

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
  end

  scenario 'PQs filtered by DFA:From, DFA:To, ID:From, ID:To, Keyword' do

    puts "30) PQs filtered by DFA:From, DFA:To, ID:From, ID:To, Keyword"

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('date-for-answer', 'answer-from', '01/11/2015')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('date-for-answer', 'answer-to', '21/11/2015')

    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('deadline-date', 'deadline-from', '13/11/2015')

    within('#count'){expect(page).to have_text('7 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_date('deadline-date', 'deadline-to', '17/11/2015')

    within('#count'){expect(page).to have_text('5 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_keywords('uin-14')

    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      find('li[data-pquin="uin-14"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    within('#filters'){find_button("clear-keywords-filter").trigger("click")}

    within('#count'){expect(page).to have_text('5 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    within('#deadline-date.filter-box'){find_button("Clear").trigger("click")}

    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    within('#date-for-answer.filter-box'){find_button("Clear").trigger("click")}

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
  end

  scenario 'PQs filtered by DFA:From, DFA:To, ID:To, Status, Replying Minister, Policy Minister' do

    puts "31) PQs filtered by DFA:From, DFA:To, ID:To, Status, Replying Minister, Policy Minister"

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('date-for-answer', 'answer-from', '23/11/2015')

    within('#count'){expect(page).to have_text('7 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_date('date-for-answer', 'answer-to', '27/11/2015')

    within('#count'){expect(page).to have_text('5 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_date('deadline-date', 'deadline-to', '24/11/2015')

    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_checkbox('flag', 'Status', 'With POD')

    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      find('li[data-pquin="uin-4"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_checkbox('replying-minister', 'Replying minister', 'Simon Hughes (MP)')

    within('#count'){expect(page).to have_text('2  parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      find('li[data-pquin="uin-4"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      find('li[data-pquin="uin-7"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_checkbox('policy-minister', 'Policy minister', 'Shailesh Vara (MP)')

    within('#count'){expect(page).to have_text('1  parliamentary question out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      find('li[data-pquin="uin-4"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#policy-minister')

    within('#count'){expect(page).to have_text('2  parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      find('li[data-pquin="uin-4"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      find('li[data-pquin="uin-7"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#replying-minister')

    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      find('li[data-pquin="uin-4"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#flag')

    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    within('#deadline-date.filter-box'){find_button("Clear").trigger("click")}

    within('#count'){expect(page).to have_text('5 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    within('#date-for-answer.filter-box'){find_button("Clear").trigger("click")}

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
  end

  scenario 'PQs filtered by DFA:From, DFA:To, ID:From, ID:To, Status, Question type, Keyword' do

    puts "32) PQs filtered by DFA:From, DFA:To, ID:From, ID:To, Status, Question type, Keyword"

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('date-for-answer', 'answer-from', '16/11/2015')

    within('#count'){expect(page).to have_text('14 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_date('date-for-answer', 'answer-to', '27/11/2015')

    within('#count'){expect(page).to have_text('12 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_date('deadline-date', 'deadline-from', '17/11/2015')
    within('#count'){expect(page).to have_text('9 parliamentary questions out of 16.')}

    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_date('deadline-date', 'deadline-to', '23/11/2015')

    within('#count'){expect(page).to have_text('7 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_checkbox('flag', 'Status', 'With POD')

    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_checkbox('question-type', 'Question type', 'Ordinary')

    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      find('li[data-pquin="uin-7"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_keywords('uin-1')

    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    within('#filters'){find_button("clear-keywords-filter").trigger("click")}

    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      find('li[data-pquin="uin-7"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#question-type')

    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#flag')

    within('#count'){expect(page).to have_text('7 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    within('#deadline-date.filter-box'){find_button("Clear").trigger("click")}

    within('#count'){expect(page).to have_text('12 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    within('#date-for-answer.filter-box'){find_button("Clear").trigger("click")}

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
  end

  scenario 'PQs filtered by DFA:From, DFA:To, ID:From, Status, Replying Minister, Policy Minister, Question type, Keyword' do

    puts "33) PQs filtered by DFA:From, DFA:To, ID:From, Status, Replying Minister, Policy Minister, Question type, Keyword"

    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('date-for-answer', 'answer-from', '16/11/2015')

    within('#count'){expect(page).to have_text('14 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_date('date-for-answer', 'answer-to', '27/11/2015')

    within('#count'){expect(page).to have_text('12 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_date('deadline-date', 'deadline-from', '16/11/2015')

    within('#count'){expect(page).to have_text('10 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_checkbox('flag', 'Status', 'With POD')

    within('#count'){expect(page).to have_text('6 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_checkbox('replying-minister', 'Replying minister', 'Simon Hughes (MP)')

    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      find('li[data-pquin="uin-4"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      find('li[data-pquin="uin-7"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      find('li[data-pquin="uin-10"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_checkbox('policy-minister', 'Policy minister', 'Shailesh Vara (MP)')

    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      find('li[data-pquin="uin-4"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      find('li[data-pquin="uin-10"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_checkbox('question-type', 'Question type', 'Named Day')

    within('#count'){expect(page).to have_text('1 parliamentary question  out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      find('li[data-pquin="uin-4"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_keywords('uin-4')

    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      find('li[data-pquin="uin-4"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    within('#filters'){find_button("clear-keywords-filter").trigger("click")}

    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      find('li[data-pquin="uin-4"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#question-type')

    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      find('li[data-pquin="uin-4"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      find('li[data-pquin="uin-10"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#policy-minister')

    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      find('li[data-pquin="uin-4"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      find('li[data-pquin="uin-7"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      find('li[data-pquin="uin-10"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#replying-minister')

    within('#count'){expect(page).to have_text('6 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      expect(page).not_to have_selector('li[data-pquin="uin-9"]')
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#flag')

    within('#count'){expect(page).to have_text('10 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    within('#deadline-date.filter-box'){find_button("Clear").trigger("click")}

    within('#count'){expect(page).to have_text('12 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    within('#date-for-answer.filter-box'){find_button("Clear").trigger("click")}

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
  end

  scenario 'PQs filtered by DFA:From, DFA:To, ID:From, ID:To, Status, Replying Minister, Policy Minister, Question type, Keyword' do

    puts "34) PQs filtered by DFA:From, DFA:To, ID:From, ID:To, Status, Replying Minister, Policy Minister, Question type, Keyword"

    within('#count'){expect(page).to have_text('16 parliamentary questions')}

    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }

    test_date('date-for-answer', 'answer-from', '15/11/2015')

    within('#count'){expect(page).to have_text('15 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_date('date-for-answer', 'answer-to', '27/11/2015')

    within('#count'){expect(page).to have_text('13 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_date('deadline-date', 'deadline-from', '15/11/2015')

    within('#count'){expect(page).to have_text('11 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_date('deadline-date', 'deadline-to', '23/11/2015')

    within('#count'){expect(page).to have_text('9 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_checkbox('flag', 'Status', 'Draft Pending')

    within('#count'){expect(page).to have_text('5 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      find('li[data-pquin="uin-5"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_checkbox('replying-minister', 'Replying minister', 'Simon Hughes (MP)')

    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      find('li[data-pquin="uin-5"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      find('li[data-pquin="uin-9"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_checkbox('policy-minister', 'Policy minister', 'Lord Faulks QC')

    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      find('li[data-pquin="uin-9"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      find('li[data-pquin="uin-13"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_checkbox('question-type', 'Question type', 'Ordinary')

    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      find('li[data-pquin="uin-9"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    test_keywords('uin-9')

    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      find('li[data-pquin="uin-9"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    within('#filters'){find_button("clear-keywords-filter").trigger("click")}

    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      find('li[data-pquin="uin-9"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      expect(page).not_to have_selector('li[data-pquin="uin-13"]')
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#question-type')

    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      expect(page).not_to have_selector('li[data-pquin="uin-5"]')
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      find('li[data-pquin="uin-9"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      expect(page).not_to have_selector('li[data-pquin="uin-12"]')
      find('li[data-pquin="uin-13"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#policy-minister')

    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      find('li[data-pquin="uin-5"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      expect(page).not_to have_selector('li[data-pquin="uin-8"]')
      find('li[data-pquin="uin-9"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#replying-minister')

    within('#count'){expect(page).to have_text('5 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      find('li[data-pquin="uin-5"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-6"]')
      expect(page).not_to have_selector('li[data-pquin="uin-7"]')
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-10"]')
      expect(page).not_to have_selector('li[data-pquin="uin-11"]')
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    clear_filter('#flag')

    within('#count'){expect(page).to have_text('9 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      expect(page).not_to have_selector('li[data-pquin="uin-3"]')
      expect(page).not_to have_selector('li[data-pquin="uin-4"]')
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-14"]')
      expect(page).not_to have_selector('li[data-pquin="uin-15"]')
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    within('#deadline-date.filter-box'){find_button("Clear").trigger("click")}

    within('#count'){expect(page).to have_text('13 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li[data-pquin="uin-1"]')
      expect(page).not_to have_selector('li[data-pquin="uin-2"]')
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      expect(page).not_to have_selector('li[data-pquin="uin-16"]')
    }

    within('#date-for-answer.filter-box'){find_button("Clear").trigger("click")}

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    within('.questions-list'){
      find('li[data-pquin="uin-1"]').visible?
      find('li[data-pquin="uin-2"]').visible?
      find('li[data-pquin="uin-3"]').visible?
      find('li[data-pquin="uin-4"]').visible?
      find('li[data-pquin="uin-5"]').visible?
      find('li[data-pquin="uin-6"]').visible?
      find('li[data-pquin="uin-7"]').visible?
      find('li[data-pquin="uin-8"]').visible?
      find('li[data-pquin="uin-9"]').visible?
      find('li[data-pquin="uin-10"]').visible?
      find('li[data-pquin="uin-11"]').visible?
      find('li[data-pquin="uin-12"]').visible?
      find('li[data-pquin="uin-13"]').visible?
      find('li[data-pquin="uin-14"]').visible?
      find('li[data-pquin="uin-15"]').visible?
      find('li[data-pquin="uin-16"]').visible?
    }
  end

end
