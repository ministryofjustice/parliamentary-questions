require 'feature_helper'
require './spec/support/csv_helpers'

feature 'Transferring questions' do
  include Features::PqHelpers
  include CSVHelpers

  before(:all) do
    DBHelpers.load_feature_fixtures

    @pqs =  PQA::QuestionLoader.new.load_and_import(3)
    set_seen_by_finance
  end

  scenario "Parli-branch exports pq data as CSV" do
    create_pq_session
    visit export_path

    fill_in 'Date from', with: Date.today.strftime('%d/%m/%Y')
    fill_in 'Date to', with: Date.tomorrow.strftime('%d/%m/%Y')
    click_on 'Download CSV'
    uins = decode_csv(page.body).map { |h| h['PIN'] }
    expect(uins).to eq(@pqs.map(&:uin))
  end
end
