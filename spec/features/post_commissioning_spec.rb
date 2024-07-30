require "feature_helper"

describe "After commissioning", js: true do
  let!(:draft_pending) { (FactoryBot.create :draft_pending_pq).uin }
  let!(:with_pod) { (FactoryBot.create :with_pod_pq).uin }
  let!(:pod_cleared) { (FactoryBot.create :pod_cleared_pq).uin }
  let!(:ministerial_query) { (FactoryBot.create :ministerial_query_pq).uin }
  let!(:minister_cleared) { (FactoryBot.create :minister_cleared_pq).uin }

  before do
    create_pq_session
    click_link "In progress"
  end

  def remove_date(css_sel)
    find(css_sel).set("")
  end

  it "Parli-branch moves an accepted question to 'Draft'" do
    expect_pq_in_progress_status(draft_pending, "Draft Pending")
    in_pq_detail(draft_pending, "PQ draft") { fillin_date("#draft_answer_received") }
    expect_pq_in_progress_status(draft_pending, "With POD")
  end

  it "Question that is late by less than one hour shows overdue warning" do
    pq = Pq.find_by(uin: draft_pending)
    pq.internal_deadline = (Time.zone.now - 10.minutes).to_s
    pq.save!
    visit pq_path(pq.uin)
    click_on "PQ commission"
    expect(page).to have_css("span.fa.fa-exclamation-triangle")
  end

  it "Parli-branch moves a question to 'POD Query' and to 'POD cleared'" do
    in_pq_detail(with_pod, "POD check") { check "POD query flag" }
    expect_pq_in_progress_status(with_pod, "POD Query")

    in_pq_detail(with_pod, "POD check") do
      fillin_date("#pod_clearance")
      remove_focus_from_filter
    end
    expect_pq_in_progress_status(with_pod, "POD Cleared")
  end

  it "Parli-branch moves a question to 'With minister' and 'Minister cleared'" do
    in_pq_detail(pod_cleared, "Minister check") do
      fillin_date("#sent_to_answering_minister")
      remove_focus_from_filter
    end
    expect_pq_in_progress_status(pod_cleared, "With Minister")

    in_pq_detail(pod_cleared, "Minister check") { check "Answering minister query" }
    expect_pq_in_progress_status(pod_cleared, "Ministerial Query")

    in_pq_detail(pod_cleared, "Minister check") do
      fillin_date("#cleared_by_answering_minister")
      remove_focus_from_filter
    end
    expect_pq_in_progress_status(pod_cleared, "Minister Cleared")
  end

  it "Parli-branch moves a question to 'Answered'" do
    in_pq_detail(minister_cleared, "Answer") { fillin_date("#answer_submitted") }
    visit dashboard_in_progress_path
    expect(page.title).to match(/In progress/)
    expect(page).not_to have_text(minister_cleared)
  end

  it "Parli-branch moves a question back from 'Minister Cleared' back to 'Ministerial Query'" do
    in_pq_detail(draft_pending, "PQ draft") { fillin_date("#draft_answer_received") }
    in_pq_detail(draft_pending, "POD check") { check "POD query flag" }
    in_pq_detail(draft_pending, "POD check") { fillin_date("#pod_clearance") }
    in_pq_detail(draft_pending, "Minister check") { fillin_date("#sent_to_answering_minister") }
    in_pq_detail(draft_pending, "Minister check") { check "Answering minister query" }
    in_pq_detail(draft_pending, "Minister check") { fillin_date("#cleared_by_answering_minister") }
    expect_pq_in_progress_status(draft_pending, "Minister Cleared")

    in_pq_detail(draft_pending, "Minister check") { remove_date("#cleared_by_answering_minister") }
    expect_pq_in_progress_status(draft_pending, "Ministerial Query")
  end

  it "Parli-branch moves a question from 'Ministerial Query' back to 'With Minister'" do
    in_pq_detail(ministerial_query, "Minister check") { uncheck "Answering minister query" }
    expect_pq_in_progress_status(ministerial_query, "With Minister")
  end

  it 'Parli-branch moves a question from "With Minister" back to "Draft Pending"' do
    in_pq_detail(pod_cleared, "Minister check") { remove_date("#sent_to_answering_minister") }
    expect_pq_in_progress_status(pod_cleared, "POD Cleared")

    in_pq_detail(pod_cleared, "Minister check") { remove_date("#sent_to_answering_minister") }
    expect_pq_in_progress_status(pod_cleared, "POD Cleared")

    in_pq_detail(pod_cleared, "POD check") { remove_date("#pod_clearance") }
    expect_pq_in_progress_status(pod_cleared, "POD Query")

    in_pq_detail(pod_cleared, "POD check") { uncheck "POD query flag" }
    in_pq_detail(pod_cleared, "PQ draft") { remove_date("#draft_answer_received") }
    expect_pq_in_progress_status(pod_cleared, "Draft Pending")
  end
end
