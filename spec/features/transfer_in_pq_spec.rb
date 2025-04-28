require "feature_helper"

describe "Transferring IN questions", :js do
  def create_transferred_pq(uin, text, date = nil)
    create_pq_session
    visit transferred_new_path

    choose "House of Commons"
    fill_in "pq[uin]", with: uin
    fill_in "pq[question]", with: text
    find("#pq_dateforanswer").set date || Date.tomorrow.strftime("%d/%m/%Y")
    find("select[name = 'pq[transfer_in_ogd_id]']")
      .find(:xpath, "option[2]")
      .select_option

    find("#transfer_in_date").set Time.zone.today.strftime("%d/%m/%Y")
    remove_focus_from_filter
    click_on "Create PQ"
    sleep 2
  end

  let(:uin) { "transfer-uin-1" }
  let(:question_text) { "this is a question - t37egfcsdb" }

  before do
    DbHelpers.load_fixtures(:ogds)
  end

  it "Attempting to transfer a PQ with invalid inputs shows an error on the page" do
    invalid_date = "A" * 51
    create_transferred_pq("invalid-uin-1", "question_text", invalid_date)

    expect(page).not_to have_content("Transferred PQ was successfully created")
    expect(page).to have_content("Invalid date input!")
  end

  it "Parli branch should be able to create a transferred PQ" do
    create_transferred_pq(uin, question_text)

    expect(page).to have_title("Dashboard")
    expect(page).to have_content("Transferred PQ was successfully created")
    expect_pq_status(uin, "Transferred in")
  end

  it "Whitespace is stripped from the manually entered UIN" do
    ws_uin = "   uin with space   "
    create_transferred_pq(ws_uin, "question")

    expect_pq_status("uin with space", "Transferred in")
  end

  it "If API import contains PQ with the same UIN as the transferred PQ, it updates the details" do
    FactoryBot.create(:pq, uin:)
    loader = PQA::QuestionLoader.new
    import = PQA::Import.new(loader.client)
    imported_pq = PQA::QuestionBuilder.default(uin)

    loader.load([imported_pq])
    report = import.run(Date.yesterday, Date.tomorrow)

    expect(report).to include(updated: 1)

    create_pq_session
    visit pq_path(uin)
    expect(page).to have_title("PQ #{uin}")
    expect(page).to have_content(imported_pq.text)
    expect(page).not_to have_content(question_text)
  end
end
