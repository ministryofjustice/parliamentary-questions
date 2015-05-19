require 'feature_helper'

feature 'Metrics dashboard', js: true do

  scenario 'The dashboard page displays correctly' do
    create_pq_session
    visit metrics_dashboard_path

    expect(page).to have_content("Metrics dashboard")
  end

  scenario 'Unauthenticated metrics dashboard access redirects to login' do
    visit metrics_dashboard_path
    expect(page.current_url).to include("/users/sign_in")
  end

  scenario 'Unauthorized geckoboard JSON access displays error' do
    visit metrics_dashboard_path + ".json"
    expect(page.status_code).to eq 401
  end

  scenario 'Authorized geckoboard JSON access displays correctly' do
    page.driver.basic_authorize("test_username", "X")
    visit metrics_dashboard_path + ".json"

    expect(page.response_headers).to include("Content-Type" => "application/json; charset=utf-8")
  end
end
