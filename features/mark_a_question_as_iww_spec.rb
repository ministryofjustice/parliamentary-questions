require 'feature_helper'

feature 'Creating an "I Will Write" question', js: true, suspend_cleaner: true do
  include Features::PqHelpers

  before(:all) do
    clear_sent_mail
    DBHelpers.load_feature_fixtures

    @uin      = PQA::QuestionLoader.new.load_and_import(1).first.uin
    @iww_uin  = "#{@uin}-IWW"
    @ao       = ActionOfficer.find_by(email: 'ao1@pq.com')
    @minister = Minister.first

    set_seen_by_finance
  end

  before(:each) do
    create_pq_session
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  scenario "Parli-branch marks a question as 'I will write'" do
    commission_question(@uin, [@ao], @minister)
    accept_assignnment(@ao)
    in_pq_detail(@uin, 'PQ draft') { check 'I will write' }
    expect(page).to have_text('I will write')
  end

  scenario "Parli-branch creates an IWW follow-up question" do
    visit pq_path(@uin)
    click_on "Answer"
    click_on "Create 'I will write' follow up"

    expect_pq_in_progress_status(@iww_uin, 'Draft Pending')

    visit pq_path(@iww_uin)
    click_on "Answer"
    expect(page).not_to have_text("Create 'I will write' follow up")
    click_on "PQ commission"
    expect(page).to have_text(@ao.email)
  end

  scenario "Parli-branch clicks on the 'create IWW follow up button' for a second time" do
    visit pq_path(@uin)
    click_on "Answer"
    click_on "Create 'I will write' follow up"
    expect(page).to have_content(@iww_uin)
    expect(Pq.where(uin: @iww_uin).count).to eq(1)
  end
end
