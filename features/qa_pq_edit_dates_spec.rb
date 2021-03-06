require 'feature_helper'

feature "Testing Quick Action 'Edit PQ dates'", js: true, suspend_cleaner: true do
  include Features::PqHelpers

  before(:each) do
    DBHelpers.load_feature_fixtures

    @pq1 = FactoryBot.create :draft_pending_pq
    @pq2 = FactoryBot.create :draft_pending_pq
    @pq3 = FactoryBot.create :draft_pending_pq

    @ao = ActionOfficer.find_by(email: 'ao1@pq.com')
    @minister = Minister.first
    create_pq_session

    click_link 'In progress'
  end

  after(:each) do
    DatabaseCleaner.clean
  end

  let(:testDate) { (Time.zone.today + 3).to_s + ' 12:00' }

  scenario 'Check all elements are present' do
    expect(page).to have_css('#count', text: '3 parliamentary questions')
    within('#editDates') do
      click_on 'Edit PQ dates'
      expect(page).to have_text('No PQs selected')
      find(:css, "input[id$='qa_edit_deadline_date']")
      find(:css, "input[id$='qa_edit_draft_date']")
      find(:css, "input[id$='qa_edit_pod_date']")
      find(:css, "input[id$='qa_edit_minister_date']")
      find(:css, "input[id$='qa_edit_answered_date']")
      find(:button, 'Edit', disabled: true)
      expect(page).to have_button('Cancel')
    end
    within('#select-all-questions') { check 'select-all' }
    within('#editDates') do
      expect(page).to have_text('3 PQs selected')
      find(:button, 'Edit', disabled: false)
      expect(page).to have_button('Cancel')
    end
  end

  scenario 'A user sets the deadline date for all PQs' do
    within('#select-all-questions') { check 'select-all' }
    within('#editDates') do
      click_on 'Edit PQ dates'
      expect(page).to have_text('3 PQs selected')
      fill_in 'qa_edit_deadline_date', with: testDate
      click_on 'Edit'
    end
    expect(page).to have_css('.pq-msg-success.fade.in', text: 'Date(s) updated')
    expect(page).to have_css('#pq-frame-1 .deadline-date.text', text: testDate)
    expect(page).to have_css('#pq-frame-2 .deadline-date.text', text: testDate)
    expect(page).to have_css('#pq-frame-3 .deadline-date.text', text: testDate)
  end

  scenario "A user sets a PQ's draft date" do
    setDate('qa_edit_draft_date', 'PQ draft', 'draft_answer_received')
  end

  scenario "A user sets a PQ's POD cleared date" do
    setDate('qa_edit_pod_date', 'POD check', 'pod_clearance')
  end

  scenario "A user sets a PQ's minister cleared date" do
    setDate('qa_edit_minister_date', 'Minister check', 'cleared_by_answering_minister')
  end

  scenario "A user sets a PQ's answered date" do
    setDate('qa_edit_answered_date', 'Answer', 'answer_submitted')
  end

  def setDate(datetype, tablink, datefield)
    within('#pq-frame-3') { check 'uin-3' }
    within('#editDates') do
      click_on 'Edit PQ dates'
      expect(page).to have_text('1 PQ selected')
      fill_in datetype, with: testDate
      click_on 'Edit'
    end
    expect(page).to have_css('.pq-msg-success.fade.in', text: 'Date(s) updated')
    within('#pq-frame-1') { click_link("#{@pq1.uin}") }
    click_link(tablink)
    expect(page).to have_field('pq[' + datefield + ']', with: '')
    click_link 'In progress'
    within('#pq-frame-2') { click_link("#{@pq2.uin}") }
    click_link(tablink)
    expect(page).to have_field('pq[' + datefield + ']', with: '')
    click_link 'In progress'
    within('#pq-frame-3') { click_link("#{@pq3.uin}") }
    click_link(tablink)
    expect(page).to have_field('pq[' + datefield + ']', with: testDate)
    click_link 'In progress'
  end
end
