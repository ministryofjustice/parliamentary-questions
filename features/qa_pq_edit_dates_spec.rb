require "feature_helper"

describe "Testing Quick Action 'Edit PQ dates'", js: true do
  let(:ao) { ActionOfficer.find_by(email: "ao1@pq.com") }
  let(:minister) { Minister.first }
  let(:test_date) { "#{Time.zone.today + 3} 12:00" }
  let!(:pq1) { FactoryBot.create :draft_pending_pq }
  let!(:pq2) { FactoryBot.create :draft_pending_pq }
  let!(:pq3) { FactoryBot.create :draft_pending_pq }

  before do
    create_pq_session
    click_link "In progress"
  end

  it "Check all elements are present" do
    expect(page).to have_css("#count", text: "3 parliamentary questions")
    within("#editDates") do
      click_on "Edit PQ dates"
      expect(page).to have_text("No PQs selected")
      find(:css, "input[id$='qa_edit_deadline_date']")
      find(:css, "input[id$='qa_edit_draft_date']")
      find(:css, "input[id$='qa_edit_pod_date']")
      find(:css, "input[id$='qa_edit_minister_date']")
      find(:css, "input[id$='qa_edit_answered_date']")
      find(:button, "Edit", disabled: true)
      expect(page).to have_button("Cancel")
    end
    within("#select-all-questions") { check "select-all" }
    within("#editDates") do
      expect(page).to have_text("3 PQs selected")
      find(:button, "Edit", disabled: false)
      expect(page).to have_button("Cancel")
    end
  end

  it "A user sets the deadline date for all PQs" do
    within("#select-all-questions") { check "select-all" }
    within("#editDates") do
      click_on "Edit PQ dates"
      expect(page).to have_text("3 PQs selected")
      fill_in "qa_edit_deadline_date", with: test_date
      find(".notice").click
      click_on "Edit"
    end
    expect(page).to have_css(".pq-msg-success.fade.in", text: "Date(s) updated")
    expect(page).to have_css("#pq-frame-1 .deadline-date.text", text: test_date)
    expect(page).to have_css("#pq-frame-2 .deadline-date.text", text: test_date)
    expect(page).to have_css("#pq-frame-3 .deadline-date.text", text: test_date)
  end

  it "A user sets a PQ's draft date" do
    set_date("qa_edit_draft_date", "PQ draft", "draft_answer_received")
  end

  it "A user sets a PQ's POD cleared date" do
    set_date("qa_edit_pod_date", "POD check", "pod_clearance")
  end

  it "A user sets a PQ's minister cleared date" do
    set_date("qa_edit_minister_date", "Minister check", "cleared_by_answering_minister")
  end

  it "A user sets a PQ's answered date" do
    set_date("qa_edit_answered_date", "Answer", "answer_submitted")
  end

  def set_date(datetype, tablink, datefield)
    within("#pq-frame-3") { check "uin-3" }
    within("#editDates") do
      click_on "Edit PQ dates"
      expect(page).to have_text("1 PQ selected")
      fill_in datetype, with: test_date
      find(".notice").click
      click_on "Edit"
    end
    sleep 1
    expect(page).to have_css(".pq-msg-success.fade.in", text: "Date(s) updated")
    within("#pq-frame-1") { click_link(pq1.uin.to_s) }
    click_link(tablink)
    expect(page).to have_field("pq[#{datefield}]", with: "")
    click_link "In progress"
    within("#pq-frame-2") { click_link(pq2.uin.to_s) }
    click_link(tablink)
    expect(page).to have_field("pq[#{datefield}]", with: "")
    click_link "In progress"
    within("#pq-frame-3") { click_link(pq3.uin.to_s) }
    click_link(tablink)
    expect(page).to have_field("pq[#{datefield}]", with: "#{test_date}:00 UTC")
    click_link "In progress"
  end
end
