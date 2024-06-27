require "feature_helper"

describe "Archive session", js: true do
  it "does not allow access to non-admin users" do
    create_pq_session
    visit new_archive_path

    # redirected to the dashboard
    expect(page).to have_title("Dashboard")
  end

  context "when admin user" do
    before do
      setup_questions_and_archives
      create_admin_session
      visit new_archive_path
    end

    it "shows current archive details" do
      expect(page).to have_title("Archive PQ Session")
      within("h2") { expect(page.text).to eq("There are 16 unarchived questions") }
      within("h3") { expect(page.text).to eq("Prefixes previously used, or reserved: £, a, b") }
    end

    it "shows error if selected prefix is invalid" do
      fill_in "prefix", with: "a"
      click_button "Archive current session"
      within(".pq-msg-error") { expect(page.text).to eq("1 error prohibited this Archive from being saved:\nPrefix has already been taken") }
    end

    it "informs the user the archive has been completed" do
      fill_in "prefix", with: "d"
      click_button "Archive current session"
      within(".pq-msg-success") { expect(page.text).to eq "Current session has been archived" }
    end

    it "updates the page with new archive details" do
      fill_in "prefix", with: "d"
      click_button "Archive current session"
      within("h2") { expect(page.text).to eq("There are 0 unarchived questions") }
      within("h3") { expect(page.text).to eq("Prefixes previously used, or reserved: £, a, b, d") }
    end
  end

  def setup_questions_and_archives
    FactoryBot.create(:with_pod_pq, uin: "UIN-1", date_for_answer: Time.zone.today - 1, internal_deadline: Time.zone.today - 2, minister_id: 3, policy_minister_id: 6, question_type: "NamedDay")
    FactoryBot.create(:draft_pending_pq, uin: "UIN-2", date_for_answer: Time.zone.today - 2, internal_deadline: Time.zone.today - 3, minister_id: 3, policy_minister_id: 4, question_type: "NamedDay")
    FactoryBot.create(:with_pod_pq, uin: "UIN-3", date_for_answer: Time.zone.today - 3, internal_deadline: Time.zone.today - 4, minister_id: 3, policy_minister_id: 4, question_type: "Ordinary")
    FactoryBot.create(:with_pod_pq, uin: "UIN-4", date_for_answer: Time.zone.today - 4, internal_deadline: Time.zone.today - 5, minister_id: 5, policy_minister_id: 4, question_type: "NamedDay")
    FactoryBot.create(:draft_pending_pq, uin: "UIN-5", date_for_answer: Time.zone.today - 5, internal_deadline: Time.zone.today - 6, minister_id: 5, policy_minister_id: 4, question_type: "Ordinary")
    FactoryBot.create(:with_pod_pq, uin: "UIN-6", date_for_answer: Time.zone.today - 6, internal_deadline: Time.zone.today - 7, minister_id: 3, policy_minister_id: 4, question_type: "NamedDay")
    FactoryBot.create(:with_pod_pq, uin: "UIN-7", date_for_answer: Time.zone.today - 7, internal_deadline: Time.zone.today - 8, minister_id: 5, policy_minister_id: 6, question_type: "Ordinary")
    FactoryBot.create(:draft_pending_pq, uin: "UIN-8", date_for_answer: Time.zone.today - 8, internal_deadline: Time.zone.today - 9, minister_id: 3, policy_minister_id: 6, question_type: "Ordinary")
    FactoryBot.create(:draft_pending_pq, uin: "UIN-9", date_for_answer: Time.zone.today - 9, internal_deadline: Time.zone.today - 10, minister_id: 5, policy_minister_id: 6, question_type: "Ordinary")
    FactoryBot.create(:with_pod_pq, uin: "UIN-10", date_for_answer: Time.zone.today - 10, internal_deadline: Time.zone.today - 11, minister_id: 5, policy_minister_id: 4, question_type: "Ordinary")
    FactoryBot.create(:with_pod_pq, uin: "UIN-11", date_for_answer: Time.zone.today - 11, internal_deadline: Time.zone.today - 12, minister_id: 3, policy_minister_id: 6, question_type: "Ordinary")
    FactoryBot.create(:draft_pending_pq, uin: "UIN-12", date_for_answer: Time.zone.today - 12, internal_deadline: Time.zone.today - 13, minister_id: 5, policy_minister_id: 4, question_type: "NamedDay")
    FactoryBot.create(:draft_pending_pq, uin: "UIN-13", date_for_answer: Time.zone.today - 13, internal_deadline: Time.zone.today - 14, minister_id: 5, policy_minister_id: 6, question_type: "NamedDay")
    FactoryBot.create(:draft_pending_pq, uin: "UIN-14", date_for_answer: Time.zone.today - 14, internal_deadline: Time.zone.today - 15, minister_id: 3, policy_minister_id: 4, question_type: "Ordinary")
    FactoryBot.create(:with_pod_pq, uin: "UIN-15", date_for_answer: Time.zone.today - 15, internal_deadline: Time.zone.today - 16, minister_id: 5, policy_minister_id: 6, question_type: "NamedDay")
    FactoryBot.create(:draft_pending_pq, uin: "UIN-16", date_for_answer: Time.zone.today - 16, internal_deadline: Time.zone.today - 17, minister_id: 3, policy_minister_id: 6, question_type: "NamedDay")

    FactoryBot.create(:archive, prefix: "£")
    FactoryBot.create(:archive, prefix: "a")
    FactoryBot.create(:archive, prefix: "b")
  end
end
