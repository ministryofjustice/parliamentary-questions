require 'feature_helper'

feature "dashboard/in_progress filtering:", js: true, suspend_cleaner: true do

  include Features::PqHelpers

  before(:all) do
    clear_sent_mail
    DBHelpers.load_feature_fixtures
    setup_questions
  end

  before(:each) do
    create_pq_session
    visit dashboard_path
    click_link 'In progress'
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  def setup_questions
    pq1 = FactoryGirl.create( :with_pod_pq, uin: 'UIN-1', date_for_answer: Date.today+16, internal_deadline: Date.today+14, minister_id: 3, policy_minister_id: 6, question_type: 'NamedDay' )
    pq2 = FactoryGirl.create( :draft_pending_pq, uin: 'UIN-2', date_for_answer: Date.today+15, internal_deadline: Date.today+13, minister_id: 3, policy_minister_id: 4, question_type: 'NamedDay' )
    pq3 = FactoryGirl.create( :with_pod_pq, uin: 'UIN-3', date_for_answer: Date.today+14, internal_deadline: Date.today+12, minister_id: 3, policy_minister_id: 4, question_type: 'Ordinary' )
    pq4 = FactoryGirl.create( :with_pod_pq, uin: 'UIN-4', date_for_answer: Date.today+13, internal_deadline: Date.today+11, minister_id: 5, policy_minister_id: 4, question_type: 'NamedDay' )
    pq5 = FactoryGirl.create( :draft_pending_pq, uin: 'UIN-5', date_for_answer: Date.today+12, internal_deadline: Date.today+10, minister_id: 5, policy_minister_id: 4, question_type: 'Ordinary')
    pq6 = FactoryGirl.create( :with_pod_pq, uin: 'UIN-6', date_for_answer: Date.today+11, internal_deadline: Date.today+9, minister_id: 3, policy_minister_id: 4, question_type: 'NamedDay' )
    pq7 = FactoryGirl.create( :with_pod_pq, uin: 'UIN-7', date_for_answer: Date.today+10, internal_deadline: Date.today+8, minister_id: 5, policy_minister_id: 6, question_type: 'Ordinary' )
    pq8 = FactoryGirl.create( :draft_pending_pq, uin: 'UIN-8', date_for_answer: Date.today+9, internal_deadline: Date.today+7, minister_id: 3, policy_minister_id: 6, question_type: 'Ordinary' )
    pq9 = FactoryGirl.create( :draft_pending_pq, uin: 'UIN-9', date_for_answer: Date.today+8, internal_deadline: Date.today+6, minister_id: 5, policy_minister_id: 6, question_type: 'Ordinary' )
    pq10 = FactoryGirl.create( :with_pod_pq, uin: 'UIN-10', date_for_answer: Date.today+7, internal_deadline: Date.today+5, minister_id: 5, policy_minister_id: 4, question_type: 'Ordinary' )
    pq11 = FactoryGirl.create( :with_pod_pq, uin: 'UIN-11', date_for_answer: Date.today+6, internal_deadline: Date.today+4, minister_id: 3, policy_minister_id: 6, question_type: 'Ordinary' )
    pq12 = FactoryGirl.create( :draft_pending_pq, uin: 'UIN-12', date_for_answer: Date.today+5, internal_deadline: Date.today+3, minister_id: 5, policy_minister_id: 4, question_type: 'NamedDay' )
    pq13 = FactoryGirl.create( :draft_pending_pq, uin: 'UIN-13', date_for_answer: Date.today+4, internal_deadline: Date.today+2, minister_id: 5, policy_minister_id: 6, question_type: 'NamedDay' )
    pq14 = FactoryGirl.create( :draft_pending_pq, uin: 'UIN-14', date_for_answer: Date.today+3, internal_deadline: Date.today+1, minister_id: 3, policy_minister_id: 4, question_type: 'Ordinary' )
    pq15 = FactoryGirl.create( :with_pod_pq, uin: 'UIN-15', date_for_answer: Date.today+2, internal_deadline: Date.today, minister_id: 5, policy_minister_id: 6, question_type: 'NamedDay' )
    pq16 = FactoryGirl.create( :draft_pending_pq, uin: 'UIN-16', date_for_answer:  Date.today+1, internal_deadline: Date.today-1, minister_id: 3, policy_minister_id: 6, question_type: 'NamedDay' )
  end

  def test_date (filterBox, id, date)
    within(filterBox+'.filter-box'){ fill_in id, :with => date }
  end

  def test_checkbox(filterBox, category, term)
    within(filterBox+'.filter-box'){
      find_button(category).trigger('click')
      choose(term)
      within('.notice') { expect(page).to have_text('1 selected') }
    }
  end

  def test_keywords(term)
    fill_in 'keywords', :with => term
  end

  def clear_filter(filterName)
    within(filterName+'.filter-box') {
      find_button('Clear').trigger('click')
      expect(page).not_to have_text('1 selected')
    }
  end

  def all_pqs_visible
    Capybara.using_wait_time 10 do
      within('.questions-list'){
        find('li#pq-frame-16').visible?
        find('li#pq-frame-16').visible?
        find('li#pq-frame-15').visible?
        find('li#pq-frame-14').visible?
        find('li#pq-frame-13').visible?
        find('li#pq-frame-12').visible?
        find('li#pq-frame-11').visible?
        find('li#pq-frame-10').visible?
        find('li#pq-frame-9').visible?
        find('li#pq-frame-8').visible?
        find('li#pq-frame-7').visible?
        find('li#pq-frame-6').visible?
        find('li#pq-frame-5').visible?
        find('li#pq-frame-4').visible?
        find('li#pq-frame-3').visible?
        find('li#pq-frame-2').visible?
        find('li#pq-frame-1').visible?
      }
    end
  end

  def all_pqs_hidden
    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end
  end

  # ======================================================================== #

  scenario '1) Test Date for Answer: From today -10 days.' do
    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#date-for-answer', 'answer-from', Date.today-10)
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

    clear_filter('#date-for-answer')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '2) Test Date for Answer: From today +9 days.' do
    test_date('#date-for-answer', 'answer-from', Date.today+9)
    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        find('li#pq-frame-8').visible?
        find('li#pq-frame-7').visible?
        find('li#pq-frame-6').visible?
        find('li#pq-frame-5').visible?
        find('li#pq-frame-4').visible?
        find('li#pq-frame-3').visible?
        find('li#pq-frame-2').visible?
        find('li#pq-frame-1').visible?
      }
    end

    clear_filter('#date-for-answer')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '3) Test Date for Answer: From today +20 days.' do
    test_date('#date-for-answer', 'answer-from', Date.today+20)
    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    all_pqs_hidden

    clear_filter('#date-for-answer')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '4) Test Date for Answer: To today -10 days.' do
    test_date('#date-for-answer', 'answer-to', Date.today-10)
    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    all_pqs_hidden

    clear_filter('#date-for-answer')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '5) Test Date for Answer: To today +9 days.' do
    test_date('#date-for-answer', 'answer-to', Date.today+9)
    within('#count'){expect(page).to have_text('9 parliamentary questions out of 16.')}
    Capybara.using_wait_time 10 do
      within('.questions-list'){
        find('li#pq-frame-16').visible?
        find('li#pq-frame-15').visible?
        find('li#pq-frame-14').visible?
        find('li#pq-frame-13').visible?
        find('li#pq-frame-12').visible?
        find('li#pq-frame-11').visible?
        find('li#pq-frame-10').visible?
        find('li#pq-frame-9').visible?
        find('li#pq-frame-8').visible?
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    clear_filter('#date-for-answer')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '6) Test Date for Answer: To today +20 days.' do
    test_date('#date-for-answer', 'answer-to', Date.today+20)
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

    clear_filter('#date-for-answer')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '7) Test Internal Deadline: From today -10 days.' do
    test_date('#internal-deadline', 'deadline-from', Date.today-10)
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

    clear_filter('#internal-deadline')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '8) Test Internal Deadline: From today +9 days.' do
    test_date('#internal-deadline', 'deadline-from', Date.today+9)
    within('#count'){expect(page).to have_text('6 parliamentary questions out of 16')}
    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        find('li#pq-frame-6').visible?
        find('li#pq-frame-5').visible?
        find('li#pq-frame-4').visible?
        find('li#pq-frame-3').visible?
        find('li#pq-frame-2').visible?
        find('li#pq-frame-1').visible?
      }
    end

    clear_filter('#internal-deadline')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '9) Test Internal Deadline: From today +20 days.' do
    test_date('#internal-deadline', 'deadline-from', Date.today+20)
    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    all_pqs_hidden

    clear_filter('#internal-deadline')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '10) Test Internal Deadline: To today -10 days.' do
    test_date('#internal-deadline', 'deadline-to', Date.today-10)
    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    all_pqs_hidden

    clear_filter('#internal-deadline')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '11) Test Internal Deadline: To today +9 days.' do
    test_date('#internal-deadline', 'deadline-to',  Date.today+9)
    within('#count'){expect(page).to have_text('11 parliamentary questions out of 16.')}
    Capybara.using_wait_time 10 do
      within('.questions-list'){
        find('li#pq-frame-16').visible?
        find('li#pq-frame-15').visible?
        find('li#pq-frame-14').visible?
        find('li#pq-frame-13').visible?
        find('li#pq-frame-12').visible?
        find('li#pq-frame-11').visible?
        find('li#pq-frame-10').visible?
        find('li#pq-frame-9').visible?
        find('li#pq-frame-8').visible?
        find('li#pq-frame-7').visible?
        find('li#pq-frame-6').visible?
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    clear_filter('#internal-deadline')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '12) Test Internal Deadline: To today +20 days.' do
    test_date('#internal-deadline', 'deadline-to', Date.today+20)
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

    clear_filter('#internal-deadline')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '13) Test the Status filter.' do
    test_checkbox('#flag', 'Status', 'With POD')
    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        find('li#pq-frame-15').visible?
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        find('li#pq-frame-11').visible?
        find('li#pq-frame-10').visible?
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        find('li#pq-frame-7').visible?
        find('li#pq-frame-6').visible?
        expect(page).not_to have_selector('li#pq-frame-5')
        find('li#pq-frame-4').visible?
        find('li#pq-frame-3').visible?
        expect(page).not_to have_selector('li#pq-frame-2')
        find('li#pq-frame-1').visible?
      }
    end

    clear_filter('#flag')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '14) Test the Replying Minister filter.' do
    test_checkbox('#replying-minister', 'Replying minister', 'Jeremy Wright (MP)')
    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    Capybara.using_wait_time 10 do
      within('.questions-list'){
        find('li#pq-frame-16').visible?
        expect(page).not_to have_selector('li#pq-frame-15')
        find('li#pq-frame-14').visible?
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        find('li#pq-frame-11').visible?
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        find('li#pq-frame-8').visible?
        expect(page).not_to have_selector('li#pq-frame-7')
        find('li#pq-frame-6').visible?
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        find('li#pq-frame-3').visible?
        find('li#pq-frame-2').visible?
        find('li#pq-frame-1').visible?
      }
    end

    clear_filter('#replying-minister')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '15) Test the Policy Minister filter.' do
    test_checkbox('#policy-minister', 'Policy minister', 'Lord Faulks QC')
    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    Capybara.using_wait_time 10 do
      within('.questions-list'){
        find('li#pq-frame-16').visible?
        find('li#pq-frame-15').visible?
        expect(page).not_to have_selector('li#pq-frame-14')
        find('li#pq-frame-13').visible?
        expect(page).not_to have_selector('li#pq-frame-12')
        find('li#pq-frame-11').visible?
        expect(page).not_to have_selector('li#pq-frame-10')
        find('li#pq-frame-9').visible?
        find('li#pq-frame-8').visible?
        find('li#pq-frame-7').visible?
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        find('li#pq-frame-1').visible?
      }
    end

    clear_filter('#policy-minister')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '16) Test the Question Type filter.' do
    test_checkbox('#question-type', 'Question type', 'Ordinary')
    within('#count') { expect(page).to have_text('8 parliamentary questions out of 16.') }
    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        find('li#pq-frame-14').visible?
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        find('li#pq-frame-11').visible?
        find('li#pq-frame-10').visible?
        find('li#pq-frame-9').visible?
        find('li#pq-frame-8').visible?
        find('li#pq-frame-7').visible?
        expect(page).not_to have_selector('li#pq-frame-6')
        find('li#pq-frame-5').visible?
        expect(page).not_to have_selector('li#pq-frame-4')
        find('li#pq-frame-3').visible?
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    clear_filter('#question-type')

    within('#count') { expect(page).to have_text('16 parliamentary questions out of 16.') }
    all_pqs_visible
  end

  scenario '17) Test the Keywords filter: All questions returned.' do
    test_keywords('UIN')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

    test_keywords('')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '18) Test the Keywords filter: Eight questions returned.' do
    test_keywords('uin-1')
    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}
    Capybara.using_wait_time 10 do
      within('.questions-list'){
        find('li#pq-frame-16').visible?
        find('li#pq-frame-15').visible?
        find('li#pq-frame-14').visible?
        find('li#pq-frame-13').visible?
        find('li#pq-frame-12').visible?
        find('li#pq-frame-11').visible?
        find('li#pq-frame-10').visible?
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        find('li#pq-frame-1').visible?
      }
    end

    test_keywords('')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '19) Test the Keywords filter: No questions returned.' do
    test_keywords('Ministry of Justice')
    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    all_pqs_hidden

    test_keywords('')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '20) Testing Date for Answer ranges: All questions returned.' do
    within('#count'){expect(page).to have_text('16 parliamentary questions')}
    all_pqs_visible

    test_date('#date-for-answer', 'answer-from', Date.today-10)
    test_date('#date-for-answer', 'answer-to', Date.today+20)
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '21) Testing Date for Answer ranges: Two questions returned.' do
    test_date('#date-for-answer', 'answer-from', Date.today+13)
    test_date('#date-for-answer', 'answer-to', Date.today+14)
    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        find('li#pq-frame-4').visible?
        find('li#pq-frame-3').visible?
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    clear_filter('#date-for-answer')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '22) Testing Date for Answer ranges: No questions returned.' do
    test_date('#date-for-answer', 'answer-from', Date.today+18)
    test_date('#date-for-answer', 'answer-to', Date.today+20)
    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    all_pqs_hidden

    clear_filter('#date-for-answer')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '23) Testing Internal Deadline ranges: All questions returned.' do
    test_date('#internal-deadline', 'deadline-from', Date.today-10)
    test_date('#internal-deadline', 'deadline-to', Date.today+20)
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

    clear_filter('#internal-deadline')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '24) Testing Internal Deadline ranges: Two questions returned.' do
    test_date('#internal-deadline', 'deadline-from', Date.today+11)
    test_date('#internal-deadline', 'deadline-to', Date.today+12)
    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        find('li#pq-frame-4').visible?
        find('li#pq-frame-3').visible?
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    clear_filter('#internal-deadline')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '25) Testing Internal Deadline ranges: No questions returned.' do
    test_date('#internal-deadline', 'deadline-from', Date.today+18)
    test_date('#internal-deadline', 'deadline-to', Date.today+20)
    within('#count'){expect(page).to have_text('0 parliamentary questions out of 16.')}
    all_pqs_hidden

    clear_filter('#internal-deadline')
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '26) Testing 2 options: Replying Minister, Policy Minister.' do
    test_checkbox('#replying-minister', 'Replying minister', 'Jeremy Wright (MP)')
    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        find('li#pq-frame-16').visible?
        expect(page).not_to have_selector('li#pq-frame-15')
        find('li#pq-frame-14').visible?
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        find('li#pq-frame-11').visible?
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        find('li#pq-frame-8').visible?
        expect(page).not_to have_selector('li#pq-frame-7')
        find('li#pq-frame-6').visible?
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        find('li#pq-frame-3').visible?
        find('li#pq-frame-2').visible?
        find('li#pq-frame-1').visible?
      }
    end

    test_checkbox('#policy-minister', 'Policy minister', 'Lord Faulks QC')
    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        find('li#pq-frame-16').visible?
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        find('li#pq-frame-11').visible?
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        find('li#pq-frame-8').visible?
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        find('li#pq-frame-1').visible?
      }
    end

    clear_filter('#policy-minister')

    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        find('li#pq-frame-16').visible?
        expect(page).not_to have_selector('li#pq-frame-15')
        find('li#pq-frame-14').visible?
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        find('li#pq-frame-11').visible?
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        find('li#pq-frame-8').visible?
        expect(page).not_to have_selector('li#pq-frame-7')
        find('li#pq-frame-6').visible?
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        find('li#pq-frame-3').visible?
        find('li#pq-frame-2').visible?
        find('li#pq-frame-1').visible?
      }
    end

    clear_filter('#replying-minister')

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '27) Testing 3 options: DFA(To), ID(From), Replying Minister.' do
    test_date('#date-for-answer', 'answer-to', Date.today+11)
    within('#count'){expect(page).to have_text('11 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        find('li#pq-frame-16').visible?
        find('li#pq-frame-15').visible?
        find('li#pq-frame-14').visible?
        find('li#pq-frame-13').visible?
        find('li#pq-frame-12').visible?
        find('li#pq-frame-11').visible?
        find('li#pq-frame-10').visible?
        find('li#pq-frame-9').visible?
        find('li#pq-frame-8').visible?
        find('li#pq-frame-7').visible?
        find('li#pq-frame-6').visible?
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end


    test_date('#internal-deadline', 'deadline-from', Date.today+4)
    within('#count'){expect(page).to have_text('6 parliamentary questions out of 16.')}
    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        find('li#pq-frame-11').visible?
        find('li#pq-frame-10').visible?
        find('li#pq-frame-9').visible?
        find('li#pq-frame-8').visible?
        find('li#pq-frame-7').visible?
        find('li#pq-frame-6').visible?
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end


    test_checkbox('#replying-minister', 'Replying minister', 'Simon Hughes (MP)')
    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        find('li#pq-frame-10').visible?
        find('li#pq-frame-9').visible?
        expect(page).not_to have_selector('li#pq-frame-8')
        find('li#pq-frame-7').visible?
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    clear_filter('#replying-minister')
    within('#count'){expect(page).to have_text('6 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        find('li#pq-frame-11').visible?
        find('li#pq-frame-10').visible?
        find('li#pq-frame-9').visible?
        find('li#pq-frame-8').visible?
        find('li#pq-frame-7').visible?
        find('li#pq-frame-6').visible?
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    within('#filters #internal-deadline.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('11 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        find('li#pq-frame-16').visible?
        find('li#pq-frame-15').visible?
        find('li#pq-frame-14').visible?
        find('li#pq-frame-13').visible?
        find('li#pq-frame-12').visible?
        find('li#pq-frame-11').visible?
        find('li#pq-frame-10').visible?
        find('li#pq-frame-9').visible?
        find('li#pq-frame-8').visible?
        find('li#pq-frame-7').visible?
        find('li#pq-frame-6').visible?
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    within('#filters #date-for-answer.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '28) Testing 4 options: DFA(From), ID(To), Replying Minister, Question type.' do
    test_date('#date-for-answer', 'answer-from', Date.today+13)
    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        find('li#pq-frame-4').visible?
        find('li#pq-frame-3').visible?
        find('li#pq-frame-2').visible?
        find('li#pq-frame-1').visible?
      }
    end

    test_date('#internal-deadline', 'deadline-to', Date.today+13)
    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        find('li#pq-frame-4').visible?
        find('li#pq-frame-3').visible?
        find('li#pq-frame-2').visible?
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    test_checkbox('#replying-minister', 'Replying minister', 'Jeremy Wright (MP)')
    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        find('li#pq-frame-3').visible?
        find('li#pq-frame-2').visible?
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    test_checkbox('#question-type', 'Question type', 'Ordinary')
    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        find('li#pq-frame-3').visible?
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    clear_filter('#question-type')
    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        find('li#pq-frame-3').visible?
        find('li#pq-frame-2').visible?
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    clear_filter('#replying-minister')
    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        find('li#pq-frame-4').visible?
        find('li#pq-frame-3').visible?
        find('li#pq-frame-2').visible?
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    within('#filters #internal-deadline.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        find('li#pq-frame-4').visible?
        find('li#pq-frame-3').visible?
        find('li#pq-frame-2').visible?
        find('li#pq-frame-1').visible?
      }
    end

    within('#filters #date-for-answer.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '29) Testing 5 options: DFA(From), DFA(To), ID(From), ID(To), Keyword.' do
    test_date('#date-for-answer', 'answer-from', Date.today-2)
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

    test_date('#date-for-answer', 'answer-to', Date.today+8)
    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        find('li#pq-frame-16').visible?
        find('li#pq-frame-15').visible?
        find('li#pq-frame-14').visible?
        find('li#pq-frame-13').visible?
        find('li#pq-frame-12').visible?
        find('li#pq-frame-11').visible?
        find('li#pq-frame-10').visible?
        find('li#pq-frame-9').visible?
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    test_date('#internal-deadline', 'deadline-from', Date.today)
    within('#count'){expect(page).to have_text('7 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        find('li#pq-frame-15').visible?
        find('li#pq-frame-14').visible?
        find('li#pq-frame-13').visible?
        find('li#pq-frame-12').visible?
        find('li#pq-frame-11').visible?
        find('li#pq-frame-10').visible?
        find('li#pq-frame-9').visible?
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    test_date('#internal-deadline', 'deadline-to', Date.today+4)
    within('#count'){expect(page).to have_text('5 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        find('li#pq-frame-15').visible?
        find('li#pq-frame-14').visible?
        find('li#pq-frame-13').visible?
        find('li#pq-frame-12').visible?
        find('li#pq-frame-11').visible?
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    test_keywords('uin-14')
    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        find('li#pq-frame-14').visible?
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    within('#filters'){find_button("clear-keywords-filter").trigger("click")}
    within('#count'){expect(page).to have_text('5 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        find('li#pq-frame-15').visible?
        find('li#pq-frame-14').visible?
        find('li#pq-frame-13').visible?
        find('li#pq-frame-12').visible?
        find('li#pq-frame-11').visible?
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    within('#internal-deadline.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('8 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        find('li#pq-frame-16').visible?
        find('li#pq-frame-15').visible?
        find('li#pq-frame-14').visible?
        find('li#pq-frame-13').visible?
        find('li#pq-frame-12').visible?
        find('li#pq-frame-11').visible?
        find('li#pq-frame-10').visible?
        find('li#pq-frame-9').visible?
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    within('#date-for-answer.filter-box'){find_button("Clear").trigger("click")}

    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '30) Testing 6 options: DFA(From), DFA(To), ID(To), Status, Replying Minister, Policy Minister.' do
    test_date('#date-for-answer', 'answer-from', Date.today+10)
    within('#count'){expect(page).to have_text('7 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        find('li#pq-frame-7').visible?
        find('li#pq-frame-6').visible?
        find('li#pq-frame-5').visible?
        find('li#pq-frame-4').visible?
        find('li#pq-frame-3').visible?
        find('li#pq-frame-2').visible?
        find('li#pq-frame-1').visible?
      }
    end

    test_date('#date-for-answer', 'answer-to', Date.today+14)
    within('#count'){expect(page).to have_text('5 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        find('li#pq-frame-7').visible?
        find('li#pq-frame-6').visible?
        find('li#pq-frame-5').visible?
        find('li#pq-frame-4').visible?
        find('li#pq-frame-3').visible?
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    test_date('#internal-deadline', 'deadline-to', Date.today+11)
    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        find('li#pq-frame-7').visible?
        find('li#pq-frame-6').visible?
        find('li#pq-frame-5').visible?
        find('li#pq-frame-4').visible?
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    test_checkbox('#flag', 'Status', 'With POD')
    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        find('li#pq-frame-7').visible?
        find('li#pq-frame-6').visible?
        expect(page).not_to have_selector('li#pq-frame-5')
        find('li#pq-frame-4').visible?
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    test_checkbox('#replying-minister', 'Replying minister', 'Simon Hughes (MP)')
    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        find('li#pq-frame-7').visible?
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        find('li#pq-frame-4').visible?
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    test_checkbox('#policy-minister', 'Policy minister', 'Shailesh Vara (MP)')
    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        find('li#pq-frame-4').visible?
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    clear_filter('#policy-minister')
    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        find('li#pq-frame-7').visible?
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        find('li#pq-frame-4').visible?
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    clear_filter('#replying-minister')
    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        find('li#pq-frame-7').visible?
        find('li#pq-frame-6').visible?
        expect(page).not_to have_selector('li#pq-frame-5')
        find('li#pq-frame-4').visible?
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    clear_filter('#flag')
    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        find('li#pq-frame-7').visible?
        find('li#pq-frame-6').visible?
        find('li#pq-frame-5').visible?
        find('li#pq-frame-4').visible?
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    within('#internal-deadline.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('5 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        expect(page).not_to have_selector('li#pq-frame-9')
        expect(page).not_to have_selector('li#pq-frame-8')
        find('li#pq-frame-7').visible?
        find('li#pq-frame-6').visible?
        find('li#pq-frame-5').visible?
        find('li#pq-frame-4').visible?
        find('li#pq-frame-3').visible?
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    within('#date-for-answer.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '31) Testing 7 options: DFA(From), DFA(To), Status, Replying Minister, Policy Minister, Question type, Keyword.' do
    test_date('#date-for-answer', 'answer-from', Date.today-10)
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible

    test_date('#date-for-answer', 'answer-to', Date.today+12)
    within('#count'){expect(page).to have_text('12 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        find('li#pq-frame-16').visible?
        find('li#pq-frame-15').visible?
        find('li#pq-frame-14').visible?
        find('li#pq-frame-13').visible?
        find('li#pq-frame-12').visible?
        find('li#pq-frame-11').visible?
        find('li#pq-frame-10').visible?
        find('li#pq-frame-9').visible?
        find('li#pq-frame-8').visible?
        find('li#pq-frame-7').visible?
        find('li#pq-frame-6').visible?
        find('li#pq-frame-5').visible?
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    test_checkbox('#flag', 'Status', 'Draft Pending')
    within('#count'){expect(page).to have_text('7 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        find('li#pq-frame-16').visible?
        expect(page).not_to have_selector('li#pq-frame-15')
        find('li#pq-frame-14').visible?
        find('li#pq-frame-13').visible?
        find('li#pq-frame-12').visible?
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        find('li#pq-frame-9').visible?
        find('li#pq-frame-8').visible?
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        find('li#pq-frame-5').visible?
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    test_checkbox('#replying-minister', 'Replying minister', 'Simon Hughes (MP)')
    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        find('li#pq-frame-13').visible?
        find('li#pq-frame-12').visible?
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        find('li#pq-frame-9').visible?
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        find('li#pq-frame-5').visible?
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    test_checkbox('#policy-minister', 'Policy minister', 'Lord Faulks QC')
    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        find('li#pq-frame-13').visible?
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        find('li#pq-frame-9').visible?
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    test_checkbox('#question-type', 'Question type', 'Ordinary')
    within('#count'){expect(page).to have_text('1 parliamentary question  out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        find('li#pq-frame-9').visible?
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    test_keywords('uin-9')
    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        find('li#pq-frame-9').visible?
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    within('#filters'){find_button("clear-keywords-filter").trigger("click")}
    within('#count'){expect(page).to have_text('1 parliamentary question  out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        expect(page).not_to have_selector('li#pq-frame-13')
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        find('li#pq-frame-9').visible?
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    clear_filter('#question-type')
    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        find('li#pq-frame-13').visible?
        expect(page).not_to have_selector('li#pq-frame-12')
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        find('li#pq-frame-9').visible?
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        expect(page).not_to have_selector('li#pq-frame-5')
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    clear_filter('#policy-minister')
    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        expect(page).not_to have_selector('li#pq-frame-16')
        expect(page).not_to have_selector('li#pq-frame-15')
        expect(page).not_to have_selector('li#pq-frame-14')
        find('li#pq-frame-13').visible?
        find('li#pq-frame-12').visible?
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        find('li#pq-frame-9').visible?
        expect(page).not_to have_selector('li#pq-frame-8')
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        find('li#pq-frame-5').visible?
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    clear_filter('#replying-minister')
    within('#count'){expect(page).to have_text('7 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        find('li#pq-frame-16').visible?
        expect(page).not_to have_selector('li#pq-frame-15')
        find('li#pq-frame-14').visible?
        find('li#pq-frame-13').visible?
        find('li#pq-frame-12').visible?
        expect(page).not_to have_selector('li#pq-frame-11')
        expect(page).not_to have_selector('li#pq-frame-10')
        find('li#pq-frame-9').visible?
        find('li#pq-frame-8').visible?
        expect(page).not_to have_selector('li#pq-frame-7')
        expect(page).not_to have_selector('li#pq-frame-6')
        find('li#pq-frame-5').visible?
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    clear_filter('#flag')
    within('#count'){expect(page).to have_text('12 parliamentary questions out of 16.')}

    Capybara.using_wait_time 10 do
      within('.questions-list'){
        find('li#pq-frame-16').visible?
        find('li#pq-frame-15').visible?
        find('li#pq-frame-14').visible?
        find('li#pq-frame-13').visible?
        find('li#pq-frame-12').visible?
        find('li#pq-frame-11').visible?
        find('li#pq-frame-10').visible?
        find('li#pq-frame-9').visible?
        find('li#pq-frame-8').visible?
        find('li#pq-frame-7').visible?
        find('li#pq-frame-6').visible?
        find('li#pq-frame-5').visible?
        expect(page).not_to have_selector('li#pq-frame-4')
        expect(page).not_to have_selector('li#pq-frame-3')
        expect(page).not_to have_selector('li#pq-frame-2')
        expect(page).not_to have_selector('li#pq-frame-1')
      }
    end

    within('#date-for-answer.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '32) Testing 8 options: DFA(From), DFA(To), ID(From), Status, Replying Minister, Policy Minister, Question type, Keyword.' do
    test_date('#date-for-answer', 'answer-from', Date.today+3)
    within('#count'){expect(page).to have_text('14 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      find('li#pq-frame-14').visible?
      find('li#pq-frame-13').visible?
      find('li#pq-frame-12').visible?
      find('li#pq-frame-11').visible?
      find('li#pq-frame-10').visible?
      find('li#pq-frame-9').visible?
      find('li#pq-frame-8').visible?
      find('li#pq-frame-7').visible?
      find('li#pq-frame-6').visible?
      find('li#pq-frame-5').visible?
      find('li#pq-frame-4').visible?
      find('li#pq-frame-3').visible?
      find('li#pq-frame-2').visible?
      find('li#pq-frame-1').visible?
    }

    test_date('#date-for-answer', 'answer-to', Date.today+14)
    within('#count'){expect(page).to have_text('12 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      find('li#pq-frame-14').visible?
      find('li#pq-frame-13').visible?
      find('li#pq-frame-12').visible?
      find('li#pq-frame-11').visible?
      find('li#pq-frame-10').visible?
      find('li#pq-frame-9').visible?
      find('li#pq-frame-8').visible?
      find('li#pq-frame-7').visible?
      find('li#pq-frame-6').visible?
      find('li#pq-frame-5').visible?
      find('li#pq-frame-4').visible?
      find('li#pq-frame-3').visible?
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    test_date('#internal-deadline', 'deadline-from', Date.today+3)
    within('#count'){expect(page).to have_text('10 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      expect(page).not_to have_selector('li#pq-frame-13')
      find('li#pq-frame-12').visible?
      find('li#pq-frame-11').visible?
      find('li#pq-frame-10').visible?
      find('li#pq-frame-9').visible?
      find('li#pq-frame-8').visible?
      find('li#pq-frame-7').visible?
      find('li#pq-frame-6').visible?
      find('li#pq-frame-5').visible?
      find('li#pq-frame-4').visible?
      find('li#pq-frame-3').visible?
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    test_checkbox('#flag', 'Status', 'With POD')
    within('#count'){expect(page).to have_text('6 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      expect(page).not_to have_selector('li#pq-frame-13')
      expect(page).not_to have_selector('li#pq-frame-12')
      find('li#pq-frame-11').visible?
      find('li#pq-frame-10').visible?
      expect(page).not_to have_selector('li#pq-frame-9')
      expect(page).not_to have_selector('li#pq-frame-8')
      find('li#pq-frame-7').visible?
      find('li#pq-frame-6').visible?
      expect(page).not_to have_selector('li#pq-frame-5')
      find('li#pq-frame-4').visible?
      find('li#pq-frame-3').visible?
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    test_checkbox('#replying-minister', 'Replying minister', 'Simon Hughes (MP)')
    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      expect(page).not_to have_selector('li#pq-frame-13')
      expect(page).not_to have_selector('li#pq-frame-12')
      expect(page).not_to have_selector('li#pq-frame-11')
      find('li#pq-frame-10').visible?
      expect(page).not_to have_selector('li#pq-frame-9')
      expect(page).not_to have_selector('li#pq-frame-8')
      find('li#pq-frame-7').visible?
      expect(page).not_to have_selector('li#pq-frame-6')
      expect(page).not_to have_selector('li#pq-frame-5')
      find('li#pq-frame-4').visible?
      expect(page).not_to have_selector('li#pq-frame-3')
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    test_checkbox('#policy-minister', 'Policy minister', 'Shailesh Vara (MP)')
    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      expect(page).not_to have_selector('li#pq-frame-13')
      expect(page).not_to have_selector('li#pq-frame-12')
      expect(page).not_to have_selector('li#pq-frame-11')
      find('li#pq-frame-10').visible?
      expect(page).not_to have_selector('li#pq-frame-9')
      expect(page).not_to have_selector('li#pq-frame-8')
      expect(page).not_to have_selector('li#pq-frame-7')
      expect(page).not_to have_selector('li#pq-frame-6')
      expect(page).not_to have_selector('li#pq-frame-5')
      find('li#pq-frame-4').visible?
      expect(page).not_to have_selector('li#pq-frame-3')
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    test_checkbox('#question-type', 'Question type', 'Named Day')
    within('#count'){expect(page).to have_text('1 parliamentary question  out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      expect(page).not_to have_selector('li#pq-frame-13')
      expect(page).not_to have_selector('li#pq-frame-12')
      expect(page).not_to have_selector('li#pq-frame-11')
      expect(page).not_to have_selector('li#pq-frame-10')
      expect(page).not_to have_selector('li#pq-frame-9')
      expect(page).not_to have_selector('li#pq-frame-8')
      expect(page).not_to have_selector('li#pq-frame-7')
      expect(page).not_to have_selector('li#pq-frame-6')
      expect(page).not_to have_selector('li#pq-frame-5')
      find('li#pq-frame-4').visible?
      expect(page).not_to have_selector('li#pq-frame-3')
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    test_keywords('uin-4')
    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      expect(page).not_to have_selector('li#pq-frame-13')
      expect(page).not_to have_selector('li#pq-frame-12')
      expect(page).not_to have_selector('li#pq-frame-11')
      expect(page).not_to have_selector('li#pq-frame-10')
      expect(page).not_to have_selector('li#pq-frame-9')
      expect(page).not_to have_selector('li#pq-frame-8')
      expect(page).not_to have_selector('li#pq-frame-7')
      expect(page).not_to have_selector('li#pq-frame-6')
      expect(page).not_to have_selector('li#pq-frame-5')
      find('li#pq-frame-4').visible?
      expect(page).not_to have_selector('li#pq-frame-3')
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    within('#filters'){find_button("clear-keywords-filter").trigger("click")}
    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      expect(page).not_to have_selector('li#pq-frame-13')
      expect(page).not_to have_selector('li#pq-frame-12')
      expect(page).not_to have_selector('li#pq-frame-11')
      expect(page).not_to have_selector('li#pq-frame-10')
      expect(page).not_to have_selector('li#pq-frame-9')
      expect(page).not_to have_selector('li#pq-frame-8')
      expect(page).not_to have_selector('li#pq-frame-7')
      expect(page).not_to have_selector('li#pq-frame-6')
      expect(page).not_to have_selector('li#pq-frame-5')
      find('li#pq-frame-4').visible?
      expect(page).not_to have_selector('li#pq-frame-3')
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    clear_filter('#question-type')
    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      expect(page).not_to have_selector('li#pq-frame-13')
      expect(page).not_to have_selector('li#pq-frame-12')
      expect(page).not_to have_selector('li#pq-frame-11')
      find('li#pq-frame-10').visible?
      expect(page).not_to have_selector('li#pq-frame-9')
      expect(page).not_to have_selector('li#pq-frame-8')
      expect(page).not_to have_selector('li#pq-frame-7')
      expect(page).not_to have_selector('li#pq-frame-6')
      expect(page).not_to have_selector('li#pq-frame-5')
      find('li#pq-frame-4').visible?
      expect(page).not_to have_selector('li#pq-frame-3')
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    clear_filter('#policy-minister')
    within('#count'){expect(page).to have_text('3 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      expect(page).not_to have_selector('li#pq-frame-13')
      expect(page).not_to have_selector('li#pq-frame-12')
      expect(page).not_to have_selector('li#pq-frame-11')
      find('li#pq-frame-10').visible?
      expect(page).not_to have_selector('li#pq-frame-9')
      expect(page).not_to have_selector('li#pq-frame-8')
      find('li#pq-frame-7').visible?
      expect(page).not_to have_selector('li#pq-frame-6')
      expect(page).not_to have_selector('li#pq-frame-5')
      find('li#pq-frame-4').visible?
      expect(page).not_to have_selector('li#pq-frame-3')
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    clear_filter('#replying-minister')
    within('#count'){expect(page).to have_text('6 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      expect(page).not_to have_selector('li#pq-frame-13')
      expect(page).not_to have_selector('li#pq-frame-12')
      find('li#pq-frame-11').visible?
      find('li#pq-frame-10').visible?
      expect(page).not_to have_selector('li#pq-frame-9')
      expect(page).not_to have_selector('li#pq-frame-8')
      find('li#pq-frame-7').visible?
      find('li#pq-frame-6').visible?
      expect(page).not_to have_selector('li#pq-frame-5')
      find('li#pq-frame-4').visible?
      find('li#pq-frame-3').visible?
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    clear_filter('#flag')
    within('#count'){expect(page).to have_text('10 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      expect(page).not_to have_selector('li#pq-frame-13')
      find('li#pq-frame-12').visible?
      find('li#pq-frame-11').visible?
      find('li#pq-frame-10').visible?
      find('li#pq-frame-9').visible?
      find('li#pq-frame-8').visible?
      find('li#pq-frame-7').visible?
      find('li#pq-frame-6').visible?
      find('li#pq-frame-5').visible?
      find('li#pq-frame-4').visible?
      find('li#pq-frame-3').visible?
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    within('#internal-deadline.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('12 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      find('li#pq-frame-14').visible?
      find('li#pq-frame-13').visible?
      find('li#pq-frame-12').visible?
      find('li#pq-frame-11').visible?
      find('li#pq-frame-10').visible?
      find('li#pq-frame-9').visible?
      find('li#pq-frame-8').visible?
      find('li#pq-frame-7').visible?
      find('li#pq-frame-6').visible?
      find('li#pq-frame-5').visible?
      find('li#pq-frame-4').visible?
      find('li#pq-frame-3').visible?
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    within('#date-for-answer.filter-box'){find_button("Clear").trigger("click")}
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

  scenario '33) Testing 9 options: DFA(From), DFA(To), ID(From), ID(To), Status, Replying Minister, Policy Minister, Question type, Keyword.' do
    test_date('#date-for-answer', 'answer-from', Date.today+2)
    within('#count'){expect(page).to have_text('15 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      find('li#pq-frame-15').visible?
      find('li#pq-frame-14').visible?
      find('li#pq-frame-13').visible?
      find('li#pq-frame-12').visible?
      find('li#pq-frame-11').visible?
      find('li#pq-frame-10').visible?
      find('li#pq-frame-9').visible?
      find('li#pq-frame-8').visible?
      find('li#pq-frame-7').visible?
      find('li#pq-frame-6').visible?
      find('li#pq-frame-5').visible?
      find('li#pq-frame-4').visible?
      find('li#pq-frame-3').visible?
      find('li#pq-frame-2').visible?
      find('li#pq-frame-1').visible?
    }

    test_date('#date-for-answer', 'answer-to', Date.today+14)
    within('#count'){expect(page).to have_text('13 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      find('li#pq-frame-15').visible?
      find('li#pq-frame-14').visible?
      find('li#pq-frame-13').visible?
      find('li#pq-frame-12').visible?
      find('li#pq-frame-11').visible?
      find('li#pq-frame-10').visible?
      find('li#pq-frame-9').visible?
      find('li#pq-frame-8').visible?
      find('li#pq-frame-7').visible?
      find('li#pq-frame-6').visible?
      find('li#pq-frame-5').visible?
      find('li#pq-frame-4').visible?
      find('li#pq-frame-3').visible?
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    test_date('#internal-deadline', 'deadline-from', Date.today+2)
    within('#count'){expect(page).to have_text('11 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      find('li#pq-frame-13').visible?
      find('li#pq-frame-12').visible?
      find('li#pq-frame-11').visible?
      find('li#pq-frame-10').visible?
      find('li#pq-frame-9').visible?
      find('li#pq-frame-8').visible?
      find('li#pq-frame-7').visible?
      find('li#pq-frame-6').visible?
      find('li#pq-frame-5').visible?
      find('li#pq-frame-4').visible?
      find('li#pq-frame-3').visible?
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    test_date('#internal-deadline', 'deadline-to', Date.today+10)
    within('#count'){expect(page).to have_text('9 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      find('li#pq-frame-13').visible?
      find('li#pq-frame-12').visible?
      find('li#pq-frame-11').visible?
      find('li#pq-frame-10').visible?
      find('li#pq-frame-9').visible?
      find('li#pq-frame-8').visible?
      find('li#pq-frame-7').visible?
      find('li#pq-frame-6').visible?
      find('li#pq-frame-5').visible?
      expect(page).not_to have_selector('li#pq-frame-4')
      expect(page).not_to have_selector('li#pq-frame-3')
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    test_checkbox('#flag', 'Status', 'With POD')
    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      expect(page).not_to have_selector('li#pq-frame-13')
      expect(page).not_to have_selector('li#pq-frame-12')
      find('li#pq-frame-11').visible?
      find('li#pq-frame-10').visible?
      expect(page).not_to have_selector('li#pq-frame-9')
      expect(page).not_to have_selector('li#pq-frame-8')
      find('li#pq-frame-7').visible?
      find('li#pq-frame-6').visible?
      expect(page).not_to have_selector('li#pq-frame-5')
      expect(page).not_to have_selector('li#pq-frame-4')
      expect(page).not_to have_selector('li#pq-frame-3')
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    test_checkbox('#replying-minister', 'Replying minister', 'Simon Hughes (MP)')
    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      expect(page).not_to have_selector('li#pq-frame-13')
      expect(page).not_to have_selector('li#pq-frame-12')
      expect(page).not_to have_selector('li#pq-frame-11')
      find('li#pq-frame-10').visible?
      expect(page).not_to have_selector('li#pq-frame-9')
      expect(page).not_to have_selector('li#pq-frame-8')
      find('li#pq-frame-7').visible?
      expect(page).not_to have_selector('li#pq-frame-6')
      expect(page).not_to have_selector('li#pq-frame-5')
      expect(page).not_to have_selector('li#pq-frame-4')
      expect(page).not_to have_selector('li#pq-frame-3')
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    test_checkbox('#policy-minister', 'Policy minister', 'Lord Faulks QC')
    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      expect(page).not_to have_selector('li#pq-frame-13')
      expect(page).not_to have_selector('li#pq-frame-12')
      expect(page).not_to have_selector('li#pq-frame-11')
      expect(page).not_to have_selector('li#pq-frame-10')
      expect(page).not_to have_selector('li#pq-frame-9')
      expect(page).not_to have_selector('li#pq-frame-8')
      find('li#pq-frame-7').visible?
      expect(page).not_to have_selector('li#pq-frame-6')
      expect(page).not_to have_selector('li#pq-frame-5')
      expect(page).not_to have_selector('li#pq-frame-4')
      expect(page).not_to have_selector('li#pq-frame-3')
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    test_checkbox('#question-type', 'Question type', 'Ordinary')
    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      expect(page).not_to have_selector('li#pq-frame-13')
      expect(page).not_to have_selector('li#pq-frame-12')
      expect(page).not_to have_selector('li#pq-frame-11')
      expect(page).not_to have_selector('li#pq-frame-10')
      expect(page).not_to have_selector('li#pq-frame-9')
      expect(page).not_to have_selector('li#pq-frame-8')
      find('li#pq-frame-7').visible?
      expect(page).not_to have_selector('li#pq-frame-6')
      expect(page).not_to have_selector('li#pq-frame-5')
      expect(page).not_to have_selector('li#pq-frame-4')
      expect(page).not_to have_selector('li#pq-frame-3')
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    test_keywords('uin-7')
    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      expect(page).not_to have_selector('li#pq-frame-13')
      expect(page).not_to have_selector('li#pq-frame-12')
      expect(page).not_to have_selector('li#pq-frame-11')
      expect(page).not_to have_selector('li#pq-frame-10')
      expect(page).not_to have_selector('li#pq-frame-9')
      expect(page).not_to have_selector('li#pq-frame-8')
      find('li#pq-frame-7').visible?
      expect(page).not_to have_selector('li#pq-frame-6')
      expect(page).not_to have_selector('li#pq-frame-5')
      expect(page).not_to have_selector('li#pq-frame-4')
      expect(page).not_to have_selector('li#pq-frame-3')
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    within('#filters'){find_button("clear-keywords-filter").trigger("click")}
    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      expect(page).not_to have_selector('li#pq-frame-13')
      expect(page).not_to have_selector('li#pq-frame-12')
      expect(page).not_to have_selector('li#pq-frame-11')
      expect(page).not_to have_selector('li#pq-frame-10')
      expect(page).not_to have_selector('li#pq-frame-9')
      expect(page).not_to have_selector('li#pq-frame-8')
      find('li#pq-frame-7').visible?
      expect(page).not_to have_selector('li#pq-frame-6')
      expect(page).not_to have_selector('li#pq-frame-5')
      expect(page).not_to have_selector('li#pq-frame-4')
      expect(page).not_to have_selector('li#pq-frame-3')
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    clear_filter('#question-type')
    within('#count'){expect(page).to have_text('1 parliamentary question out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      expect(page).not_to have_selector('li#pq-frame-13')
      expect(page).not_to have_selector('li#pq-frame-12')
      expect(page).not_to have_selector('li#pq-frame-11')
      expect(page).not_to have_selector('li#pq-frame-10')
      expect(page).not_to have_selector('li#pq-frame-9')
      expect(page).not_to have_selector('li#pq-frame-8')
      find('li#pq-frame-7').visible?
      expect(page).not_to have_selector('li#pq-frame-6')
      expect(page).not_to have_selector('li#pq-frame-5')
      expect(page).not_to have_selector('li#pq-frame-4')
      expect(page).not_to have_selector('li#pq-frame-3')
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    clear_filter('#policy-minister')
    within('#count'){expect(page).to have_text('2 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      expect(page).not_to have_selector('li#pq-frame-13')
      expect(page).not_to have_selector('li#pq-frame-12')
      expect(page).not_to have_selector('li#pq-frame-11')
      find('li#pq-frame-10').visible?
      expect(page).not_to have_selector('li#pq-frame-9')
      expect(page).not_to have_selector('li#pq-frame-8')
      find('li#pq-frame-7').visible?
      expect(page).not_to have_selector('li#pq-frame-6')
      expect(page).not_to have_selector('li#pq-frame-5')
      expect(page).not_to have_selector('li#pq-frame-4')
      expect(page).not_to have_selector('li#pq-frame-3')
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    clear_filter('#replying-minister')
    within('#count'){expect(page).to have_text('4 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      expect(page).not_to have_selector('li#pq-frame-13')
      expect(page).not_to have_selector('li#pq-frame-12')
      find('li#pq-frame-11').visible?
      find('li#pq-frame-10').visible?
      expect(page).not_to have_selector('li#pq-frame-9')
      expect(page).not_to have_selector('li#pq-frame-8')
      find('li#pq-frame-7').visible?
      find('li#pq-frame-6').visible?
      expect(page).not_to have_selector('li#pq-frame-5')
      expect(page).not_to have_selector('li#pq-frame-4')
      expect(page).not_to have_selector('li#pq-frame-3')
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    clear_filter('#flag')
    within('#count'){expect(page).to have_text('9 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      expect(page).not_to have_selector('li#pq-frame-15')
      expect(page).not_to have_selector('li#pq-frame-14')
      find('li#pq-frame-13').visible?
      find('li#pq-frame-12').visible?
      find('li#pq-frame-11').visible?
      find('li#pq-frame-10').visible?
      find('li#pq-frame-9').visible?
      find('li#pq-frame-8').visible?
      find('li#pq-frame-7').visible?
      find('li#pq-frame-6').visible?
      find('li#pq-frame-5').visible?
      expect(page).not_to have_selector('li#pq-frame-4')
      expect(page).not_to have_selector('li#pq-frame-3')
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    within('#internal-deadline.filter-box'){find_button('Clear').trigger('click')}
    within('#count'){expect(page).to have_text('13 parliamentary questions out of 16.')}
    within('.questions-list'){
      expect(page).not_to have_selector('li#pq-frame-16')
      find('li#pq-frame-15').visible?
      find('li#pq-frame-14').visible?
      find('li#pq-frame-13').visible?
      find('li#pq-frame-12').visible?
      find('li#pq-frame-11').visible?
      find('li#pq-frame-10').visible?
      find('li#pq-frame-9').visible?
      find('li#pq-frame-8').visible?
      find('li#pq-frame-7').visible?
      find('li#pq-frame-6').visible?
      find('li#pq-frame-5').visible?
      find('li#pq-frame-4').visible?
      find('li#pq-frame-3').visible?
      expect(page).not_to have_selector('li#pq-frame-2')
      expect(page).not_to have_selector('li#pq-frame-1')
    }

    within('#date-for-answer.filter-box'){find_button('Clear').trigger('click')}
    within('#count'){expect(page).to have_text('16 parliamentary questions out of 16.')}
    all_pqs_visible
  end

end
