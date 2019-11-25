require 'feature_helper'

feature 'Send draft reminders from the dashboard', js: true, suspend_cleaner: true do
  include Features::PqHelpers

  before(:each) do
    # clear_sent_mail
    DBHelpers.load_feature_fixtures
    @pq1, @pq2, @pq3 = PQA::QuestionLoader.new.load_and_import(3)
    @uin1 = @pq1.uin
    @uin2 = @pq2.uin
    @uin3 = @pq3.uin
    @ao = ActionOfficer.find_by(email: 'ao1@pq.com')
    @minister = Minister.first
  end

  after(:each) do
    DatabaseCleaner.clean
  end

  scenario 'A user sends draft reminders for all PQs' do
    initialise
    check 'select-all'
    within('#draftReminders') do
      click_on 'Send Draft Reminders'
      expect(page).to have_text('3 PQs selected')
      expect(page).to have_button('Cancel')
      find(:button, 'Send', disabled: false)
      click_button('Send')
      expect(page).to have_selector('#draftReminders .content', visible: false)
    end
    within('.pq-msg-success.fade.in') do
      expect(page).to have_text('Draft Reminder(s) Sent')
    end
  end

  scenario 'A user cancels draft reminders for all PQs' do
    initialise
    check 'select-all'
    within('#draftReminders') do
      click_on 'Send Draft Reminders'
      expect(page).to have_text('3 PQs selected')
      expect(page).to have_button('Cancel')
      find(:button, 'Send', disabled: false)
      click_button('Cancel')
      expect(page).to have_selector('#draftReminders .content', visible: false)
    end
  end

  def accept_commission(pq, ao)
    # ao_mail = sent_mail.first
    visit_assignment_url(pq, ao)
    choose 'Accept'
    click_on 'Save Response'
    visit dashboard_path
    # clear_sent_mail
  end

  def initialise
    commission_question(@uin1, [@ao], @minister)
    accept_commission(@pq1, @ao)
    commission_question(@uin2, [@ao], @minister)
    accept_commission(@pq2, @ao)
    commission_question(@uin3, [@ao], @minister)
    accept_commission(@pq3, @ao)
    click_link 'In progress'
  end
end
