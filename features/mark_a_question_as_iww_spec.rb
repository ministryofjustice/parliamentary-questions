require "feature_helper"

describe 'Creating an "I Will Write" question', js: true, suspend_cleaner: true do
  include Features::PqHelpers

  let(:dummy_ao)        { ActionOfficer.find_by(email: "ao1@pq.com") }
  let(:dummy_uin)       { PQA::QuestionLoader.new.load_and_import(1).first.uin }
  let(:dummy_iww_uin)   { "#{dummy_uin}-IWW" }
  let(:dummy_minister)  { Minister.first }

  before do
    DbHelpers.load_feature_fixtures
    create_pq_session
  end

  after do
    DatabaseCleaner.clean
  end

  it "Parli-branch marks a question as 'I will write'" do
    commission_question(dummy_uin, [dummy_ao], dummy_minister)
    accept_assignment(Pq.find_by(uin: dummy_uin), dummy_ao)
    in_pq_detail(dummy_uin, "PQ draft") { check "I will write" }

    expect(page).to have_title("PQ #{dummy_uin}")
    expect(page).to have_text("I will write")
  end

  it "Parli-branch creates an IWW follow-up question" do
    visit pq_path(dummy_uin)
    click_on "Answer"
    click_on "Create 'I will write' follow up"

    visit dashboard_path
    expect(page.title).to match(/Dashboard/)
    expect(page).not_to have_text(dummy_uin)

    expect_pq_in_progress_status(dummy_iww_uin, "Draft Pending")

    visit pq_path(dummy_iww_uin)

    click_on "Answer"
    expect(page).not_to have_text("Create 'I will write' follow up")
    click_on "PQ commission"
    expect(page.title).to have_text("PQ #{dummy_iww_uin}")
    expect(page).to have_text(dummy_ao.email)
  end

  it "Parli-branch clicks on the 'create IWW follow up button' for a second time" do
    visit pq_path(dummy_uin)
    click_on "Answer"
    click_on "Create 'I will write' follow up"
    expect(page.title).to have_text("PQ #{dummy_iww_uin}")
    expect(page).to have_content(dummy_iww_uin)
    expect(Pq.where(uin: dummy_iww_uin).count).to eq(1)
  end
end
