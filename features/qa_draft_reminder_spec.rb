require 'feature_helper'

feature 'Send draft reminders from the dashboard', js: true, suspend_cleaner: true do
  include Features::PqHelpers

  before(:each) do
    DBHelpers.load_feature_fixtures
    @pq1 = FactoryBot.create :draft_pending_pq
    @pq2 = FactoryBot.create :draft_pending_pq
    @pq3 = FactoryBot.create :draft_pending_pq
    create_pq_session

    click_link 'In progress'
  end

  after(:each) do
    DatabaseCleaner.clean
  end

  scenario 'A user sends draft reminders for all PQs' do
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
end
