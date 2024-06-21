require "feature_helper"
require "./spec/support/csv_helpers"

describe "Exporting PQ data to CSV" do
  include CSVHelpers

  let!(:pqs) { PQA::QuestionLoader.new.load_and_import(3) }

  it "Parli-branch can export pq data as CSV" do
    create_pq_session
    visit export_path

    fill_in "Date from", with: Time.zone.today.strftime("%d/%m/%Y")
    fill_in "Date to", with: Date.tomorrow.strftime("%d/%m/%Y")
    click_on "Download CSV"

    uins = decode_csv(page.body).map { |h| h["PIN"] }

    expect(uins).to eq(pqs.map(&:uin))
  end

  it "Incorrect date input will show an error on the page" do
    create_pq_session
    visit export_path

    fill_in "Date from", with: Time.zone.today.strftime("%d/%m/%Y")
    fill_in "Date to", with: "A" * 100
    click_on "Download CSV"

    expect(page).to have_content "Invalid date input!"
  end
end
