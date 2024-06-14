require "feature_helper"

describe "'Backlog' page filtering:", js: true, suspend_cleaner: true do
  include Features::PqHelpers

  before do
    DatabaseCleaner.clean
    DbHelpers.load_feature_fixtures
    setup_questions
    create_pq_session
    visit dashboard_backlog_path
  end

  after do
    DatabaseCleaner.clean
  end

  it "1) by Date for Answer (From: 20 days ago)." do
    within("#count") { expect(page.text).to eq("16 parliamentary questions") }
    all_pqs(16, "visible")
    test_date("#date-for-answer", "answer-from", Time.zone.today - 20)
    test_date("#date-for-answer", "answer-to", Time.zone.today)
    sleep(5000)
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
    clear_filter("#date-for-answer")
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "2) by Date for Answer (From: 8 days ago)." do
    test_date("#date-for-answer", "answer-from", Time.zone.today - 8)
    test_date("#date-for-answer", "answer-to", Time.zone.today)
    within("#count") { expect(page.text).to eq("8 parliamentary questions out of 16.") }
    within(".questions-list") do
      find("li#pq-frame-8").visible?
      find("li#pq-frame-7").visible?
      find("li#pq-frame-6").visible?
      find("li#pq-frame-5").visible?
      find("li#pq-frame-4").visible?
      find("li#pq-frame-3").visible?
      find("li#pq-frame-2").visible?
      find("li#pq-frame-1").visible?
    end
    clear_filter("#date-for-answer")
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "3) by Date for Answer (From: 20 days time)." do
    test_date("#date-for-answer", "answer-from", Time.zone.today + 20)
    test_date("#date-for-answer", "answer-to", Time.zone.today)
    within("#count") { expect(page.text).to eq("0 parliamentary questions out of 16.") }
    all_pqs(16, "hidden")
    clear_filter("#date-for-answer")
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "4) by Date for Answer (To: 20 days ago)." do
    test_date("#date-for-answer", "answer-from", Time.zone.today - 20)
    test_date("#date-for-answer", "answer-to", Time.zone.today - 20)
    within("#count") { expect(page.text).to eq("0 parliamentary questions out of 16.") }
    all_pqs(16, "hidden")
    clear_filter("#date-for-answer")
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "5) by Date for Answer (To: 8 days ago)." do
    test_date("#date-for-answer", "answer-from", Time.zone.today - 20)
    test_date("#date-for-answer", "answer-to", Time.zone.today - 8)
    within("#count") { expect(page.text).to eq("9 parliamentary questions out of 16.") }
    within(".questions-list") do
      find("li#pq-frame-16").visible?
      find("li#pq-frame-15").visible?
      find("li#pq-frame-14").visible?
      find("li#pq-frame-13").visible?
      find("li#pq-frame-12").visible?
      find("li#pq-frame-11").visible?
      find("li#pq-frame-10").visible?
      find("li#pq-frame-9").visible?
      find("li#pq-frame-8").visible?
    end
    clear_filter("#date-for-answer")
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "6) by Date for Answer (To: 20 days time)." do
    test_date("#date-for-answer", "answer-from", Time.zone.today)
    test_date("#date-for-answer", "answer-to", Time.zone.today + 20)
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
    clear_filter("#date-for-answer")
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "7) by Internal Deadline (From: 20 days ago)." do
    test_date("#internal-deadline", "deadline-from", Time.zone.today - 20)
    test_date("#date-for-answer", "answer-to", Time.zone.today)
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
    clear_filter("#internal-deadline")
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "8) by Internal Deadline (From: 7 days ago)." do
    test_date("#internal-deadline", "deadline-from", Time.zone.today - 7)
    test_date("#date-for-answer", "answer-to", Time.zone.today)
    within("#count") { expect(page.text).to eq("6 parliamentary questions out of 16") }
    within(".questions-list") do
      find("li#pq-frame-6").visible?
      find("li#pq-frame-5").visible?
      find("li#pq-frame-4").visible?
      find("li#pq-frame-3").visible?
      find("li#pq-frame-2").visible?
      find("li#pq-frame-1").visible?
    end
    clear_filter("#internal-deadline")
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "9) by Internal Deadline (From: 20 days time)." do
    test_date("#internal-deadline", "deadline-from", Time.zone.today + 20)
    test_date("#date-for-answer", "answer-to", Time.zone.today + 20)
    within("#count") { expect(page.text).to eq("0 parliamentary questions out of 16.") }
    all_pqs(16, "hidden")
    clear_filter("#internal-deadline")
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "10) by Internal Deadline (To: 20 days ago)." do
    test_date("#internal-deadline", "deadline-from", Time.zone.today + 20)
    test_date("#internal-deadline", "deadline-to", Time.zone.today - 20)
    within("#count") { expect(page.text).to eq("0 parliamentary questions out of 16.") }
    all_pqs(16, "hidden")
    clear_filter("#internal-deadline")
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "11) by Internal Deadline (To: 7 days ago)." do
    test_date("#internal-deadline", "deadline-from", Time.zone.today + 20)
    test_date("#internal-deadline", "deadline-to", Time.zone.today - 7)
    within("#count") { expect(page.text).to eq("11 parliamentary questions out of 16.") }
    within(".questions-list") do
      find("li#pq-frame-16").visible?
      find("li#pq-frame-15").visible?
      find("li#pq-frame-14").visible?
      find("li#pq-frame-13").visible?
      find("li#pq-frame-12").visible?
      find("li#pq-frame-11").visible?
      find("li#pq-frame-10").visible?
      find("li#pq-frame-9").visible?
      find("li#pq-frame-8").visible?
      find("li#pq-frame-7").visible?
      find("li#pq-frame-6").visible?
    end
    clear_filter("#internal-deadline")
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "12) by Internal Deadline (To: 10 days time)." do
    test_date("#internal-deadline", "deadline-from", Time.zone.today)
    test_date("#internal-deadline", "deadline-to", Time.zone.today + 10)
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
    clear_filter("#internal-deadline")
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "13) by Status filter" do
    test_checkbox("#flag", "Status", "With POD")
    within("#count") { expect(page.text).to eq("8 parliamentary questions out of 16.") }
    within(".questions-list") do
      find("li#pq-frame-15").visible?
      find("li#pq-frame-11").visible?
      find("li#pq-frame-10").visible?
      find("li#pq-frame-7").visible?
      find("li#pq-frame-6").visible?
      find("li#pq-frame-4").visible?
      find("li#pq-frame-3").visible?
      find("li#pq-frame-1").visible?
    end
    clear_filter("#flag")
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "14) by the Replying Minister filter" do
    test_checkbox("#replying-minister", "Replying minister", "Jeremy Wright (MP)")
    within("#count") { expect(page.text).to eq("8 parliamentary questions out of 16.") }
    within(".questions-list") do
      find("li#pq-frame-16").visible?
      find("li#pq-frame-14").visible?
      find("li#pq-frame-11").visible?
      find("li#pq-frame-8").visible?
      find("li#pq-frame-6").visible?
      find("li#pq-frame-3").visible?
      find("li#pq-frame-2").visible?
      find("li#pq-frame-1").visible?
    end
    clear_filter("#replying-minister")
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "15) by Policy Minister filter" do
    test_checkbox("#policy-minister", "Policy minister", "Lord Faulks QC")
    within("#count") { expect(page.text).to eq("8 parliamentary questions out of 16.") }
    within(".questions-list") do
      find("li#pq-frame-16").visible?
      find("li#pq-frame-15").visible?
      find("li#pq-frame-13").visible?
      find("li#pq-frame-11").visible?
      find("li#pq-frame-9").visible?
      find("li#pq-frame-8").visible?
      find("li#pq-frame-7").visible?
      find("li#pq-frame-1").visible?
    end
    clear_filter("#policy-minister")
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "16) by Question Type filter" do
    test_checkbox("#question-type", "Question type", "Ordinary")
    within("#count") { expect(page.text).to eq("8 parliamentary questions out of 16.") }
    within(".questions-list") do
      find("li#pq-frame-14").visible?
      find("li#pq-frame-11").visible?
      find("li#pq-frame-10").visible?
      find("li#pq-frame-9").visible?
      find("li#pq-frame-8").visible?
      find("li#pq-frame-7").visible?
      find("li#pq-frame-5").visible?
      find("li#pq-frame-3").visible?
    end
    clear_filter("#question-type")
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "17) by the Keywords filter: All questions returned." do
    test_keywords("UIN-")
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
    test_keywords("")
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "18) by the Keywords filter: Eight questions returned." do
    test_keywords("UIN-1")
    within("#count") { expect(page.text).to eq("8 parliamentary questions out of 16.") }
    within(".questions-list") do
      find("li#pq-frame-16").visible?
      find("li#pq-frame-15").visible?
      find("li#pq-frame-14").visible?
      find("li#pq-frame-13").visible?
      find("li#pq-frame-12").visible?
      find("li#pq-frame-11").visible?
      find("li#pq-frame-10").visible?
      find("li#pq-frame-1").visible?
    end
    test_keywords("")
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  it "19) by the Keywords filter: No questions returned." do
    test_keywords("Ministry of Justice")
    within("#count") { expect(page.text).to eq("0 parliamentary questions out of 16.") }
    all_pqs(16, "hidden")
    test_keywords("")
    within("#count") { expect(page.text).to eq("16 parliamentary questions out of 16.") }
    all_pqs(16, "visible")
  end

  def setup_questions
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
  end

  def test_date(filter_box, id, date)
    within("#{filter_box}.filter-box") { fill_in id, with: date }
  end

  def test_checkbox(filter_box, category, term)
    within("#{filter_box}.filter-box") do
      find_button(category).click
      choose(term)
      within(".notice") { expect(page.text).to eq("1 selected") }
    end
  end

  def test_keywords(term)
    fill_in "keywords", with: term
  end

  def clear_filter(filter_name)
    within("#{filter_name}.filter-box") do
      find_button("Clear").click
      expect(page).not_to have_text("1 selected")
    end
  end

  def all_pqs(number_of_questions, visibility)
    counter = 1
    within(".questions-list") do
      while number_of_questions > counter
        if visibility == "hidden"
          expect(page).not_to have_selector("li#pq-frame-#{counter}")
        else
          find("li#pq-frame-#{counter}").visible?
        end
        counter += 1
      end
    end
  end
end
