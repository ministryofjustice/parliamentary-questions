require 'feature_helper'

feature 'Tests for Dashboard multiple PQ selection', js: true, suspend_cleaner: true do

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

  scenario "Check page elements" do
    initialise
    within('#count'){
      expect(page).to have_text("3 parliamentary questions")
    }
    within('#draftReminders'){
      click_on 'Send Draft Reminders'
      expect(page).to have_text("No PQs selected")
      find(:button, 'Send', disabled: true)
    }
    within('#editDates'){
      click_on 'Edit PQ dates'
      expect(page).to have_text("No PQs selected")
      find(:button, 'Edit', disabled: true)
    }
    within('#csvExport'){
      click_on 'Export PQs to CSV'
      expect(page).to have_text("No PQs selected")
      find(:button, 'Export', disabled: true)
    }
  end

  scenario "A user selects and de-selects PQs with the 'Select all' checkbox" do
    initialise
    check 'select-all'
    within('#draftReminders'){
      click_on 'Send Draft Reminders'
      expect(page).to have_text("3 PQs selected")
      find(:button, 'Send', disabled: false)
    }
    within('#editDates'){
      click_on 'Edit PQ dates'
      expect(page).to have_text("3 PQs selected")
      find(:button, 'Edit', disabled: true)
    }
    within('#csvExport'){
      click_on 'Export PQs to CSV'
      expect(page).to have_text("3 PQs selected")
      find(:button, 'Export', disabled: false)
    }
    within('.questions-list'){
      find(:checkbox, 'uin-1', checked: true)
      find(:checkbox, 'uin-2', checked: true)
      find(:checkbox, 'uin-3', checked: true)
    }

    # A user de-selects all by clicking 'Select all' checkbox do
    uncheck 'select-all'
    within('.questions-list'){
      find(:checkbox, 'uin-1', checked: false)
      find(:checkbox, 'uin-2', checked: false)
      find(:checkbox, 'uin-3', checked: false)
    }

    # Check the No. of selected PQs is correct
    within('#draftReminders'){
      click_on 'Send Draft Reminders'
      expect(page).to have_text("No PQs selected")
      find(:button, 'Send', disabled: true)
    }
    within('#editDates'){
      click_on 'Edit PQ dates'
      expect(page).to have_text("No PQs selected")
      find(:button, 'Edit', disabled: true)
    }
    within('#csvExport'){
      click_on 'Export PQs to CSV'
      expect(page).to have_text("No PQs selected")
      find(:button, 'Export', disabled: true)
    }
  end

  scenario "A user selects individual PQs" do
    initialise

    # One question
    within('.questions-list'){
      check 'uin-3'
    }
    within('#draftReminders'){
      click_on 'Send Draft Reminders'
      expect(page).to have_text("1 PQ selected")
      find(:button, 'Send', disabled: false)
    }
    within('#editDates'){
      click_on 'Edit PQ dates'
      expect(page).to have_text("1 PQ selected")
      find(:button, 'Edit', disabled: false)
    }
    within('#csvExport'){
      click_on 'Export PQs to CSV'
      expect(page).to have_text("1 PQ selected")
      find(:button, 'Export', disabled: false)
    }

    # Second question
    within('.questions-list'){
      check 'uin-2'
    }
    within('#draftReminders'){
      click_on 'Send Draft Reminders'
      expect(page).to have_text("2 PQs selected")
      find(:button, 'Send', disabled: false)
    }
    within('#editDates'){
      click_on 'Edit PQ dates'
      expect(page).to have_text("2 PQs selected")
      find(:button, 'Edit', disabled: false)
    }
    within('#csvExport'){
      click_on 'Export PQs to CSV'
      expect(page).to have_text("2 PQs selected")
      find(:button, 'Export', disabled: false)
    }
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

end
