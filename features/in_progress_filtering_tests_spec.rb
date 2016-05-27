require 'feature_helper'

feature "In progress page filtering:", js: true, suspend_cleaner: true do

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

  scenario '33) by Date for Answer (From), Date for Answer (To), Internal Deadline (From), Internal Deadline (To), Status, Replying Minister, Policy Minister, Question type & Keyword' do
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
    all_pqs(16, 'visible')
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

  def test_date (filter_box, id, date)
    within("#{filter_box}.filter-box") { fill_in id, :with => date }
  end

  def test_checkbox(filter_box, category, term)
    within("#{filter_box}.filter-box") {
      find_button(category).trigger('click')
      choose(term)
      within('.notice') { expect(page).to have_text('1 selected') }
    }
  end

  def test_keywords(term)
    fill_in 'keywords', :with => term
  end

  def clear_filter(filter_name)
    within("#{filter_name}.filter-box") {
      find_button('Clear').trigger('click')
      expect(page).not_to have_text('1 selected')
    }
  end

  def all_pqs(number_of_questions, visibility)
    counter = 1
    within('.questions-list'){
      while number_of_questions > counter do
        if visibility == 'hidden' then
          expect(page).not_to have_selector("li#pq-frame-#{counter}")
        else
          find("li#pq-frame-#{counter}").visible?
        end
        counter += 1
      end
    }
  end

end
