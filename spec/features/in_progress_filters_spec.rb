require "feature_helper"

describe "'In progress' page filtering:", js: true do
  before do
    setup_questions
    create_pq_session
    visit dashboard_in_progress_path
  end

  it "1) by Date for Answer (From: 10 days ago)." do
    within("#count") { expect(page).to have_text("16 parliamentary questions") }
    all_pqs(16, "visible")
    test_date("#date-for-answer", "answer-from", Time.zone.today - 10)
    remove_focus_from_filter
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
    clear_filter("#date-for-answer")
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "2) by Date for Answer (From: 9 days time)." do
    test_date("#date-for-answer", "answer-from", Time.zone.today + 9)
    remove_focus_from_filter
    within("#count") { expect(page).to have_text("8 parliamentary questions out of 16.") }
    within(".questions-list") do
      find("li#pq-frame-#{@pq8.id}").visible?
      find("li#pq-frame-#{@pq7.id}").visible?
      find("li#pq-frame-#{@pq6.id}").visible?
      find("li#pq-frame-#{@pq5.id}").visible?
      find("li#pq-frame-#{@pq4.id}").visible?
      find("li#pq-frame-#{@pq3.id}").visible?
      find("li#pq-frame-#{@pq2.id}").visible?
      find("li#pq-frame-#{@pq1.id}").visible?
    end
    clear_filter("#date-for-answer")
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "3) by Date for Answer (From: 20 days time)." do
    test_date("#date-for-answer", "answer-from", Time.zone.today + 20)
    remove_focus_from_filter
    within("#count") { expect(page).to have_text("0 parliamentary questions out of 16.") }
    all_pqs(16, "hidden")
    clear_filter("#date-for-answer")
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "4) by Date for Answer (To: 10 days ago)." do
    test_date("#date-for-answer", "answer-to", Time.zone.today - 10)
    remove_focus_from_filter
    within("#count") { expect(page).to have_text("0 parliamentary questions out of 16.") }
    all_pqs(16, "hidden")
    clear_filter("#date-for-answer")
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "5) by Date for Answer (To: 9 days time)." do
    test_date("#date-for-answer", "answer-to", Time.zone.today + 9)
    remove_focus_from_filter
    within("#count") { expect(page).to have_text("9 parliamentary questions out of 16.") }
    within(".questions-list") do
      find("li#pq-frame-#{@pq16.id}").visible?
      find("li#pq-frame-#{@pq15.id}").visible?
      find("li#pq-frame-#{@pq14.id}").visible?
      find("li#pq-frame-#{@pq13.id}").visible?
      find("li#pq-frame-#{@pq12.id}").visible?
      find("li#pq-frame-#{@pq11.id}").visible?
      find("li#pq-frame-#{@pq10.id}").visible?
      find("li#pq-frame-#{@pq9.id}").visible?
      find("li#pq-frame-#{@pq8.id}").visible?
    end
    clear_filter("#date-for-answer")
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "6) by Date for Answer (To: 20 days time)." do
    test_date("#date-for-answer", "answer-to", Time.zone.today + 20)
    remove_focus_from_filter
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
    clear_filter("#date-for-answer")
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "7) by Internal Deadline (From: 10 days ago)." do
    test_date("#internal-deadline", "deadline-from", Time.zone.today - 10)
    remove_focus_from_filter
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
    clear_filter("#internal-deadline")
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "8) by Internal Deadline (From: 9 days time)." do
    test_date("#internal-deadline", "deadline-from", Time.zone.today + 9)
    remove_focus_from_filter
    within("#count") { expect(page).to have_text("6 parliamentary questions out of 16") }
    within(".questions-list") do
      find("li#pq-frame-#{@pq6.id}").visible?
      find("li#pq-frame-#{@pq5.id}").visible?
      find("li#pq-frame-#{@pq4.id}").visible?
      find("li#pq-frame-#{@pq3.id}").visible?
      find("li#pq-frame-#{@pq2.id}").visible?
      find("li#pq-frame-#{@pq1.id}").visible?
    end
    clear_filter("#internal-deadline")
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "9) by Internal Deadline (From: 20 days time)." do
    test_date("#internal-deadline", "deadline-from", Time.zone.today + 20)
    remove_focus_from_filter
    within("#count") { expect(page).to have_text("0 parliamentary questions out of 16.") }
    all_pqs(16, "hidden")
    clear_filter("#internal-deadline")
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "10) by Internal Deadline (To: 10 days ago)." do
    test_date("#internal-deadline", "deadline-to", Time.zone.today - 10)
    remove_focus_from_filter
    within("#count") { expect(page).to have_text("0 parliamentary questions out of 16.") }
    all_pqs(16, "hidden")
    clear_filter("#internal-deadline")
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "11) by Internal Deadline (To: 9 days time)." do
    test_date("#internal-deadline", "deadline-to", Time.zone.today + 9)
    remove_focus_from_filter
    within("#count") { expect(page).to have_text("11 parliamentary questions out of 16.") }
    within(".questions-list") do
      find("li#pq-frame-#{@pq16.id}").visible?
      find("li#pq-frame-#{@pq15.id}").visible?
      find("li#pq-frame-#{@pq14.id}").visible?
      find("li#pq-frame-#{@pq13.id}").visible?
      find("li#pq-frame-#{@pq12.id}").visible?
      find("li#pq-frame-#{@pq11.id}").visible?
      find("li#pq-frame-#{@pq10.id}").visible?
      find("li#pq-frame-#{@pq9.id}").visible?
      find("li#pq-frame-#{@pq8.id}").visible?
      find("li#pq-frame-#{@pq7.id}").visible?
      find("li#pq-frame-#{@pq6.id}").visible?
    end
    clear_filter("#internal-deadline")
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "12) by Internal Deadline (To: 20 days time." do
    test_date("#internal-deadline", "deadline-to", Time.zone.today + 20)
    remove_focus_from_filter
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
    clear_filter("#internal-deadline")
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "13) by the Status filter." do
    test_checkbox("#flag", "Status", "With POD")
    within("#count") { expect(page).to have_text("8 parliamentary questions out of 16.") }
    within(".questions-list") do
      find("li#pq-frame-#{@pq15.id}").visible?
      find("li#pq-frame-#{@pq11.id}").visible?
      find("li#pq-frame-#{@pq10.id}").visible?
      find("li#pq-frame-#{@pq7.id}").visible?
      find("li#pq-frame-#{@pq6.id}").visible?
      find("li#pq-frame-#{@pq4.id}").visible?
      find("li#pq-frame-#{@pq3.id}").visible?
      find("li#pq-frame-#{@pq1.id}").visible?
    end
    clear_filter("#flag")
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "14) by the Replying Minister filter." do
    test_checkbox("#replying-minister", "Replying minister", "Jeremy Wright (MP)")
    within("#count") { expect(page).to have_text("8 parliamentary questions out of 16.") }
    within(".questions-list") do
      find("li#pq-frame-#{@pq16.id}").visible?
      find("li#pq-frame-#{@pq14.id}").visible?
      find("li#pq-frame-#{@pq11.id}").visible?
      find("li#pq-frame-#{@pq8.id}").visible?
      find("li#pq-frame-#{@pq6.id}").visible?
      find("li#pq-frame-#{@pq3.id}").visible?
      find("li#pq-frame-#{@pq2.id}").visible?
      find("li#pq-frame-#{@pq1.id}").visible?
    end
    clear_filter("#replying-minister")
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "15) by the Policy Minister filter." do
    test_checkbox("#policy-minister", "Policy minister", "Lord Faulks QC")
    within("#count") { expect(page).to have_text("8 parliamentary questions out of 16.") }
    within(".questions-list") do
      find("li#pq-frame-#{@pq16.id}").visible?
      find("li#pq-frame-#{@pq15.id}").visible?
      find("li#pq-frame-#{@pq13.id}").visible?
      find("li#pq-frame-#{@pq11.id}").visible?
      find("li#pq-frame-#{@pq9.id}").visible?
      find("li#pq-frame-#{@pq8.id}").visible?
      find("li#pq-frame-#{@pq7.id}").visible?
      find("li#pq-frame-#{@pq1.id}").visible?
    end
    clear_filter("#policy-minister")
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "16) by the Question Type filter." do
    test_checkbox("#question-type", "Question type", "Ordinary")
    within("#count") { expect(page).to have_text("8 parliamentary questions out of 16.") }
    within(".questions-list") do
      find("li#pq-frame-#{@pq14.id}").visible?
      find("li#pq-frame-#{@pq11.id}").visible?
      find("li#pq-frame-#{@pq10.id}").visible?
      find("li#pq-frame-#{@pq9.id}").visible?
      find("li#pq-frame-#{@pq8.id}").visible?
      find("li#pq-frame-#{@pq7.id}").visible?
      find("li#pq-frame-#{@pq5.id}").visible?
      find("li#pq-frame-#{@pq3.id}").visible?
    end
    clear_filter("#question-type")
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "17) by the Keywords filter: All questions returned." do
    test_keywords("UIN")
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
    test_keywords("")
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "18) by the Keywords filter: Eight questions returned." do
    test_keywords("UIN-1")
    within("#count") { expect(page).to have_text("8 parliamentary questions out of 16.") }
    within(".questions-list") do
      find("li#pq-frame-#{@pq16.id}").visible?
      find("li#pq-frame-#{@pq15.id}").visible?
      find("li#pq-frame-#{@pq14.id}").visible?
      find("li#pq-frame-#{@pq13.id}").visible?
      find("li#pq-frame-#{@pq12.id}").visible?
      find("li#pq-frame-#{@pq11.id}").visible?
      find("li#pq-frame-#{@pq10.id}").visible?
      find("li#pq-frame-#{@pq1.id}").visible?
    end
    test_keywords("")
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "19) by the Keywords filter: No questions returned." do
    test_keywords("Ministry of Justice")
    within("#count") { expect(page).to have_text("0 parliamentary questions out of 16.") }
    all_pqs(16, "hidden")
    test_keywords("")
    within("#count") { expect(page).to have_text("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  def setup_questions
    DbHelpers.load_fixtures(:ministers)
    @pq1 = FactoryBot.create(:with_pod_pq, uin: "UIN-1", date_for_answer: Time.zone.today + 16, internal_deadline: Time.zone.today + 14, minister_id: 3, policy_minister_id: 6, question_type: "NamedDay")
    @pq2 = FactoryBot.create(:draft_pending_pq, uin: "UIN-2", date_for_answer: Time.zone.today + 15, internal_deadline: Time.zone.today + 13, minister_id: 3, policy_minister_id: 4, question_type: "NamedDay")
    @pq3 = FactoryBot.create(:with_pod_pq, uin: "UIN-3", date_for_answer: Time.zone.today + 14, internal_deadline: Time.zone.today + 12, minister_id: 3, policy_minister_id: 4, question_type: "Ordinary")
    @pq4 = FactoryBot.create(:with_pod_pq, uin: "UIN-4", date_for_answer: Time.zone.today + 13, internal_deadline: Time.zone.today + 11, minister_id: 5, policy_minister_id: 4, question_type: "NamedDay")
    @pq5 = FactoryBot.create(:draft_pending_pq, uin: "UIN-5", date_for_answer: Time.zone.today + 12, internal_deadline: Time.zone.today + 10, minister_id: 5, policy_minister_id: 4, question_type: "Ordinary")
    @pq6 = FactoryBot.create(:with_pod_pq, uin: "UIN-6", date_for_answer: Time.zone.today + 11, internal_deadline: Time.zone.today + 9, minister_id: 3, policy_minister_id: 4, question_type: "NamedDay")
    @pq7 = FactoryBot.create(:with_pod_pq, uin: "UIN-7", date_for_answer: Time.zone.today + 10, internal_deadline: Time.zone.today + 8, minister_id: 5, policy_minister_id: 6, question_type: "Ordinary")
    @pq8 = FactoryBot.create(:draft_pending_pq, uin: "UIN-8", date_for_answer: Time.zone.today + 9, internal_deadline: Time.zone.today + 7, minister_id: 3, policy_minister_id: 6, question_type: "Ordinary")
    @pq9 = FactoryBot.create(:draft_pending_pq, uin: "UIN-9", date_for_answer: Time.zone.today + 8, internal_deadline: Time.zone.today + 6, minister_id: 5, policy_minister_id: 6, question_type: "Ordinary")
    @pq10 = FactoryBot.create(:with_pod_pq, uin: "UIN-10", date_for_answer: Time.zone.today + 7, internal_deadline: Time.zone.today + 5, minister_id: 5, policy_minister_id: 4, question_type: "Ordinary")
    @pq11 = FactoryBot.create(:with_pod_pq, uin: "UIN-11", date_for_answer: Time.zone.today + 6, internal_deadline: Time.zone.today + 4, minister_id: 3, policy_minister_id: 6, question_type: "Ordinary")
    @pq12 = FactoryBot.create(:draft_pending_pq, uin: "UIN-12", date_for_answer: Time.zone.today + 5, internal_deadline: Time.zone.today + 3, minister_id: 5, policy_minister_id: 4, question_type: "NamedDay")
    @pq13 = FactoryBot.create(:draft_pending_pq, uin: "UIN-13", date_for_answer: Time.zone.today + 4, internal_deadline: Time.zone.today + 2, minister_id: 5, policy_minister_id: 6, question_type: "NamedDay")
    @pq14 = FactoryBot.create(:draft_pending_pq, uin: "UIN-14", date_for_answer: Time.zone.today + 3, internal_deadline: Time.zone.today + 1, minister_id: 3, policy_minister_id: 4, question_type: "Ordinary")
    @pq15 = FactoryBot.create(:with_pod_pq, uin: "UIN-15", date_for_answer: Time.zone.today + 2, internal_deadline: Time.zone.today, minister_id: 5, policy_minister_id: 6, question_type: "NamedDay")
    @pq16 = FactoryBot.create(:draft_pending_pq, uin: "UIN-16", date_for_answer: Time.zone.today + 1, internal_deadline: Time.zone.today - 1, minister_id: 3, policy_minister_id: 6, question_type: "NamedDay")
  end
end
