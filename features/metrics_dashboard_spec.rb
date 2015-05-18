require 'feature_helper'

feature 'Metrics dashboard', js: true do

  scenario 'The dashboard page displays correctly' do
    create_pq_session
    visit metrics_dashboard_path

    expect(page).to have_content("Metrics dashboard")
  end

end
