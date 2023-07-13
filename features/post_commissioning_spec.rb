require "feature_helper"

describe "After commissioning", js: true, suspend_cleaner: true do
  include Features::PqHelpers

  let(:uin1)  { (FactoryBot.create :draft_pending_pq).uin }
  let(:uin2)  { (FactoryBot.create :draft_pending_pq).uin }
  let(:uin3)  { (FactoryBot.create :draft_pending_pq).uin }

  before do
    DBHelpers.load_feature_fixtures
    create_pq_session
    click_link "In progress"
    create_pq_session
  end

  after do
    DatabaseCleaner.clean
  end

  def remove_date(css_sel)
    find(css_sel).set("")
  end

  it "Parli-branch moves an accepted question to 'Draft'" do
    expect_pq_in_progress_status(uin1, "Draft Pending")
    in_pq_detail(uin1, "PQ draft") { fillin_date("#draft_answer_received") }
    expect_pq_in_progress_status(uin1, "With POD")
  end

  it "Question that is late by less than one hour shows overdue warning" do
    pq = Pq.find_by(uin: uin3)
    pq.internal_deadline = (Time.zone.now - 10.minutes).to_s
    pq.save!
    visit pq_path(pq.uin)
    click_on "PQ commission"
    expect(page).to have_css("span.fa.fa-exclamation-triangle")
  end

  it "Parli-branch moves a question to 'POD Query' and to 'POD cleared'" do
    in_pq_detail(uin1, "POD check") { check "POD query flag" }
    expect_pq_in_progress_status(uin1, "POD Query")

    in_pq_detail(uin1, "POD check") { fillin_date("#pod_clearance") }
    expect_pq_in_progress_status(uin1, "POD Cleared")
  end

  it "Parli-branch moves a question to 'With minister' and 'Minister cleared'" do
    in_pq_detail(uin1, "Minister check") { fillin_date("#sent_to_answering_minister") }
    expect_pq_in_progress_status(uin1, "With Minister")

    in_pq_detail(uin1, "Minister check") { check "Answering minister query" }
    expect_pq_in_progress_status(uin1, "Ministerial Query")

    in_pq_detail(uin1, "Minister check") { fillin_date("#cleared_by_answering_minister") }
    expect_pq_in_progress_status(uin1, "Minister Cleared")
  end

  it "Parli-branch moves a question to 'Answered'" do
    in_pq_detail(uin1, "Answer") { fillin_date("#answer_submitted") }
    visit dashboard_in_progress_path
    expect(page.title).to match(/In progress/)
    expect(page).not_to have_text(uin1)
  end

  it "Parli-branch moves a question back from 'Minister Cleared' back to 'Ministerial Query'" do
    in_pq_detail(uin2, "PQ draft")       { fillin_date("#draft_answer_received") }
    in_pq_detail(uin2, "POD check")      { check "POD query flag" }
    in_pq_detail(uin2, "POD check")      { fillin_date("#pod_clearance") }
    in_pq_detail(uin2, "Minister check") { fillin_date("#sent_to_answering_minister") }
    in_pq_detail(uin2, "Minister check") { check "Answering minister query" }
    in_pq_detail(uin2, "Minister check") { fillin_date("#cleared_by_answering_minister") }
    expect_pq_in_progress_status(uin2, "Minister Cleared")

    in_pq_detail(uin2, "Minister check") { remove_date("#cleared_by_answering_minister") }
    expect_pq_in_progress_status(uin2, "Ministerial Query")
  end

  it "Parli-branch moves a question from 'Ministerial Query' back to 'With Minister'" do
    in_pq_detail(uin2, "Minister check") { uncheck "Answering minister query" }
    expect_pq_in_progress_status(uin2, "With Minister")
  end

  it 'Parli-branch moves a question from "With Minister" back to "Draft Pending"' do
    in_pq_detail(uin2, "Minister check") { remove_date("#sent_to_answering_minister") }
    expect_pq_in_progress_status(uin2, "POD Cleared")

    in_pq_detail(uin2, "Minister check") { remove_date("#sent_to_answering_minister") }
    expect_pq_in_progress_status(uin2, "POD Cleared")

    in_pq_detail(uin2, "POD check") { remove_date("#pod_clearance") }
    expect_pq_in_progress_status(uin2, "POD Query")

    in_pq_detail(uin2, "POD check") { uncheck "POD query flag" }
    in_pq_detail(uin2, "PQ draft")  { remove_date("#draft_answer_received") }
    expect_pq_in_progress_status(uin2, "Draft Pending")
  end
end
