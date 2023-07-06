require "feature_helper"

describe "Parli-branch re-assigns a question", js: true, suspend_cleaner: true do
  include Features::PqHelpers

  let(:ao1)      { ActionOfficer.find_by(email: "ao1@pq.com") }
  let(:ao2)      { ActionOfficer.find_by(email: "ao2@pq.com") }
  let(:minister) { Minister.first                             }

  before(:all) do
    DBHelpers.load_feature_fixtures
    @pq, = PQA::QuestionLoader.new.load_and_import(2)
  end

  after do
    DatabaseCleaner.clean
  end

  it "Parli-branch assigns question to an action officer" do
    create_pq_session
    commission_question(@pq.uin, [ao1], minister)
  end

  it "Parli-branch cannot re-assign before AO accepts question" do
    create_pq_session
    visit pq_path(@pq.uin)
    click_on "PQ commission"

    expect(page.title).to have_text("PQ #{@pq.uin}")
    expect(page).not_to have_content("Reassign action officer")
    expect(page).not_to have_content("Action officer(s)")
  end

  it "Action officer receive notification and accepts question" do
    accept_assignment(@pq, ao1)
  end

  it "Parli-branch re-assigns question to another action officer" do
    create_pq_session
    visit pq_path(@pq.uin)
    click_on "PQ commission"

    expect(page).to have_content(ao1.email)
    expect(page).not_to have_content(ao2.email)

    click_on "Manually reject this action officer"

    commission_question(@pq.uin, [ao2], minister)
    accept_assignment(@pq, ao2)

    visit pq_path(@pq.uin)
    click_on "PQ commission"

    expect(page).not_to have_content(ao1.email)
    expect(page).to have_content(ao2.email)
  end
end
