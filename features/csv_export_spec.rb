require 'feature_helper'
require './spec/support/csv_helpers'

feature 'Exporting PQ data to CSV' do
  include Features::PqHelpers
  include CSVHelpers

  before(:all) do
    DBHelpers.load_feature_fixtures

    @pqs =  PQA::QuestionLoader.new.load_and_import(3)
    set_seen_by_finance
  end

  scenario 'Parli-branch can export pq data as CSV' do
    create_pq_session
    visit export_path

    fill_in 'Date from', with: Date.today.strftime('%d/%m/%Y')
    fill_in 'Date to', with: Date.tomorrow.strftime('%d/%m/%Y')
    click_on 'Download CSV'
    uins = decode_csv(page.body).map { |h| h['PIN'] }
    expect(uins).to eq(@pqs.map(&:uin))
  end

  scenario 'Incorrect date input will show an error on the page' do
    create_pq_session
    visit export_path

    fill_in 'Date from', with: Date.today.strftime('%d/%m/%Y')
    fill_in 'Date to', with: 'A' * 100
    click_on 'Download CSV'

    expect(page.title).to have_content("Export PQs to CSV")
    expect(page).to have_content 'Invalid date input!'
  end
end
