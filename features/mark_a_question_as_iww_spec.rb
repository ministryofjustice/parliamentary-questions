require "feature_helper"

describe 'Creating an "I Will Write" question', js: true, suspend_cleaner: true do
  include Features::PqHelpers

  before(:all) do
    DBHelpers.load_feature_fixtures

    @uin      = PQA::QuestionLoader.new.load_and_import(1).first.uin
    @iww_uin  = "#{@uin}-IWW"
    @ao       = ActionOfficer.find_by(email: "ao1@pq.com")
    @minister = Minister.first
  end

  before do
    create_pq_session
  end

  after(:each) do
    DatabaseCleaner.clean
  end

  it "Parli-branch marks a question as 'I will write'" do
    commission_question(@uin, [@ao], @minister)
    accept_assignment(Pq.find_by(uin: @uin), @ao)
    in_pq_detail(@uin, "PQ draft") { check "I will write" }

    expect(page.title).to have_content("PQ #{@uin}")
    expect(page).to have_text("I will write")
  end

  it "Parli-branch creates an IWW follow-up question" do
    visit pq_path(@uin)
    click_on "Answer"
    click_on "Create 'I will write' follow up"

    visit dashboard_path
    expect(page.title).to match(/Dashboard/)
    expect(page).not_to have_text(@uin)

    expect_pq_in_progress_status(@iww_uin, "Draft Pending")

    visit pq_path(@iww_uin)

    click_on "Answer"
    expect(page).not_to have_text("Create 'I will write' follow up")
    click_on "PQ commission"
    expect(page.title).to have_text("PQ #{@iww_uin}")
    expect(page).to have_text(@ao.email)
  end

  it "Parli-branch clicks on the 'create IWW follow up button' for a second time" do
    visit pq_path(@uin)
    click_on "Answer"
    click_on "Create 'I will write' follow up"
    expect(page.title).to have_text("PQ #{@iww_uin}")
    expect(page).to have_content(@iww_uin)
    expect(Pq.where(uin: @iww_uin).count).to eq(1)
  end
end
