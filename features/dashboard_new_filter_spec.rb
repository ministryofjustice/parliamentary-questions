require 'feature_helper'

feature "User filters 'New' dashboard  questions", js: true, suspend_cleaner: true do

  include Features::PqHelpers

  before(:all) do
    clear_sent_mail
    DBHelpers.load_feature_fixtures
    generate_dummy_pq()
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  scenario "Check filter elements are on page" do
    initialise
    within("#count") { expect(page).to have_text('3 parliamentary questions') }
    within("#filters") {
      expect(find('h2')).to have_content('Filter')
      expect(page).to have_selector("input[class='view open'][type=button][value='Status']")
      expect(page).not_to have_text('1 selected')
      expect(page).not_to have_selector("div[class='list']")
      click_button "Status"
      expect(page).to have_selector("div[class='list']")
      within("#flag .list") {
        expect(find("label[for='rejected']")).to have_content('Rejected')
        expect(page).to have_selector("input[name='flag'][type=radio][value='Rejected']")
        expect(find("label[for='no_response']")).to have_content('No response')
        expect(page).to have_selector("input[name='flag'][type=radio][value='No response']")
        expect(find("label[for='unassigned']")).to have_content('Unassigned')
        expect(page).to have_selector("input[name='flag'][type=radio][value='Unassigned']")
      }
      within("#flag.filter-box .content.collapsed .clearFilter") {
        expect(page).to have_selector("input[class='clear right'][type=button][value='Clear']")
      }
    }
  end

  scenario "filter questions by status 'Unassigned'" do
    initialise
    set_status('Unassigned')
    check_visible_pqs('uin-1', 'uin-2', 'uin-3')
  end

  scenario "filter qustions by status 'No response'" do
    initialise
    set_status('No response')
    check_visible_pqs('uin-2', 'uin-1', 'uin-3')
  end

  scenario "filter qustions by status 'Rejected'" do
    initialise
    set_status('Rejected')
    check_visible_pqs('uin-3', 'uin-2', 'uin-1')
  end

  scenario "Clear all filters" do
    initialise
    set_status('No response')
    within("#flag") {
      click_button "Clear"
      expect(page).not_to have_text('1 selected')
    }
    within("#count") { expect(page).to have_text('3 parliamentary questions out of 3.') }
    within(".questions-list") {
      expect(page).to have_text('uin-1')
      expect(page).to have_text('uin-2')
      expect(page).to have_text('uin-3')
    }
  end

  private

  def generate_dummy_pq()
    PQA::QuestionLoader.new.load_and_import(3) # Generate two questions.

    # Change Q1 'Unassigned' properties
    a = Pq.first
    a.update(date_for_answer: '01/11/2015')

    # Change Q2 'No Response' properties
    a = Pq.second
    a.update(date_for_answer: '02/11/2015')
    a.update(minister_id: 4)
    a.update(policy_minister_id: 3)
    a.update(internal_deadline: '25/11/2015 11:00')
    a.update(state: 'no_response')

    # Change Q3 'No Response' properties
    a = Pq.third
    a.update(date_for_answer: '03/11/2015')
    a.update(minister_id: 1)
    a.update(policy_minister_id: 2)
    a.update(internal_deadline: '26/11/2015 11:00')
    a.update(state: 'rejected')
  end

  def initialise
    create_pq_session
    visit dashboard_path
    # Set UIN-2 & UIN-3 action officers =
    select 'action officer 1 (Corporate Finance)', :from => 'action_officers_pqs_action_officer_id_2'
    select 'action officer 1 (Corporate Finance)', :from => 'action_officers_pqs_action_officer_id_3'
  end

  def set_status(state)
    within("#flag") {
      click_button "Status"
      choose(state)
      expect(page).to have_text('1 selected')
    }
  end

  def check_visible_pqs(q1, q2, q3)
    within("#count") { expect(page).to have_text('1 parliamentary question out of 3.') }
    within(".questions-list") {
      expect(page).to have_text(q1)
      expect(page).not_to have_text(q2)
      expect(page).not_to have_text(q3)
    }
  end

end
