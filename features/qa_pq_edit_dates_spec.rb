require 'feature_helper'

feature "Testing Quick Action 'Edit PQ dates'", js: true, suspend_cleaner: true do

  include Features::PqHelpers

  before(:each) do
    clear_sent_mail
    DBHelpers.load_feature_fixtures
    pq1, pq2, pq3 = PQA::QuestionLoader.new.load_and_import(3)
    @uin1, @uin2, @uin3 = pq1.uin, pq2.uin, pq3.uin
    @ao = ActionOfficer.find_by(email: 'ao1@pq.com')
    @minister = Minister.first
  end

  after(:each) do
    DatabaseCleaner.clean
  end

  let(:testDate) { (Date.today+3).to_s + ' 12:00' }

  scenario "Check all elements are present" do
    initialise
    expect(page).to have_css("#count", text: "3 parliamentary questions")
    within('#editDates') {
      click_on 'Edit PQ dates'
      expect(page).to have_text("No PQs selected")
      find(:css, "input[id$='qa_edit_deadline_date']")
      find(:css, "input[id$='qa_edit_draft_date']")
      find(:css, "input[id$='qa_edit_pod_date']")
      find(:css, "input[id$='qa_edit_minister_date']")
      find(:css, "input[id$='qa_edit_answered_date']")
      find(:button, 'Edit', disabled: true)
      expect(page).to have_button('Cancel')
    }
    within('#select-all-questions') { check 'select-all' }
    within('#editDates') {
      expect(page).to have_text('3 PQs selected')
      find(:button, 'Edit', disabled: false)
      expect(page).to have_button('Cancel')
    }
  end

  scenario "A user sets the deadline date for all PQs" do
    initialise
    within('#select-all-questions') { check 'select-all' }
    within('#editDates') {
      click_on 'Edit PQ dates'
      expect(page).to have_text('3 PQs selected')
      fill_in 'qa_edit_deadline_date', with: testDate
      click_on 'Edit'
    }
    expect(page).to have_css(".pq-msg-success.fade.in", text: "Date(s) updated")
    expect(page).to have_css("#pq-frame-1 .deadline-date.text", text: testDate)
    expect(page).to have_css("#pq-frame-2 .deadline-date.text", text: testDate)
    expect(page).to have_css("#pq-frame-3 .deadline-date.text", text: testDate)
  end

  scenario "A user sets a PQ's draft date" do
    initialise
    setDate('qa_edit_draft_date', 'PQ draft', 'draft_answer_received')
  end

  scenario "A user sets a PQ's POD cleared date" do
    initialise
    setDate('qa_edit_pod_date', 'POD check', 'pod_clearance')
  end

  scenario "A user sets a PQ's minister cleared date" do
    initialise
    setDate('qa_edit_minister_date', 'Minister check', 'cleared_by_answering_minister')
  end

  scenario "A user sets a PQ's answered date" do
    initialise
    setDate('qa_edit_answered_date', 'Answer', 'answer_submitted')
  end

  def accept_commission()
    ao_mail = sent_mail.first
    visit_assignment_url(@ao)
    choose 'Accept'
    click_on 'Save'
    visit dashboard_path
    clear_sent_mail
  end

  def initialise()
    create_pq_session
    commission_question(@uin1, [@ao], @minister)
    accept_commission
    commission_question(@uin2, [@ao], @minister)
    accept_commission
    commission_question(@uin3, [@ao], @minister)
    accept_commission
    click_link 'In progress'
  end

  def setDate(dateType, tabLink, dateField)
    within('#pq-frame-3') { check 'uin-3' }
    within('#editDates') {
      click_on 'Edit PQ dates'
      expect(page).to have_text('1 PQ selected')
      fill_in dateType, with: testDate
      click_on 'Edit'
    }
    expect(page).to have_css('.pq-msg-success.fade.in', text: 'Date(s) updated')
    within('#pq-frame-1') { click_link('uin-1') }
    click_link(tabLink)
    expect(page).to have_field('pq['+dateField+']', with: '')
    click_link 'In progress'
    within('#pq-frame-2') { click_link('uin-2') }
    click_link(tabLink)
    expect(page).to have_field('pq['+dateField+']', with: '')
    click_link 'In progress'
    within('#pq-frame-3') { click_link('uin-3') }
    click_link(tabLink)
    expect(page).to have_field('pq['+dateField+']', with: testDate)
    click_link 'In progress'
  end
end
