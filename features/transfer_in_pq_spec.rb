require "feature_helper"

describe "Transferring IN questions", js: true, suspend_cleaner: true do
  include Features::PqHelpers

  def create_transferred_pq(uin, text, date = nil)
    create_pq_session
    visit transferred_new_path

    fill_in "pq[uin]", with: uin
    fill_in "pq[question]", with: text
    find("#pq_dateforanswer").set date || Date.tomorrow.strftime("%d/%m/%Y")
    choose "House of Commons"

    find("select[name = 'pq[transfer_in_ogd_id]']")
      .find(:xpath, "option[2]")
      .select_option

    find("#transfer_in_date").set Time.zone.today.strftime("%d/%m/%Y")
    click_on "Create PQ"
  end

  before do
    DBHelpers.load_feature_fixtures
  end

  after do
    DatabaseCleaner.clean
  end

  let(:uin)           { "transfer-uin-1"                  }
  let(:question_text) { "this is a question - t37egfcsdb" }

  it "Attempting to transfer a PQ with invalid inputs shows an error on the page" do
    invalid_date = "A" * 51
    create_transferred_pq("invalid-uin-1", "question_text", invalid_date)

    expect(page.title).to have_text("")
    expect(page).not_to have_content("Transferred PQ was successfully created")
    expect(page).to have_content("Invalid date input!")
  end

  it "Parli branch should be able to create a transferred PQ" do
    create_transferred_pq(uin, question_text)

    expect(page.title).to have_text("Dashboard")
    expect(page).to have_content("Transferred PQ was successfully created")
    expect_pq_status(uin, "Transferred in")
  end

  it "Whitespace is stripped from the manually entered UIN" do
    ws_uin = "   uin with space   "
    create_transferred_pq(ws_uin, "question")

    expect_pq_status("uin with space", "Transferred in")
  end

  it "If API import contains PQ with the same UIN as the transferred PQ, it updates the details" do
    loader      = PQA::QuestionLoader.new
    import      = PQA::Import.new
    imported_pq = PQA::QuestionBuilder.default(uin)

    loader.load([imported_pq])
    report = import.run(Date.yesterday, Date.tomorrow)

    expect(report).to include(updated: 1)

    create_pq_session
    visit pq_path(uin)
    expect(page.title).to have_text("PQ #{uin}")
    expect(page).to have_content(imported_pq.text)
    expect(page).not_to have_content(question_text)
  end
end
