require 'feature_helper'

feature 'Transferring OUT questions', js: true, suspend_cleaner: true do

  before(:all) do
    DBHelpers.load_feature_fixtures
    DBHelpers.load_fixtures(:pqs)
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  def uin
    Pq.first.uin
  end

  scenario 'Parli branch should be able to transfer out a PQ' do
    create_pq_session
    visit dashboard_path
    click_on uin
    click_on "PQ commission"

    find("select[name = 'pq[transfer_out_ogd_id]']")
      .find(:xpath, "option[2]")
      .select_option
    
    find('#transfer_out_date').set Date.today.strftime('%d/%m/%Y')
    click_on 'Save'

    expect(page).to have_content('Successfully updated')
  end

  scenario 'The transferred out PQ should have label set to "Transferred out"' do
    create_pq_session
    visit pq_path(uin)

    within('#pq-details-progress') do
      expect(page).to have_content('Transferred out')
    end
  end

  scenario 'The transferred out PQ should not be visible in the dashboard view' do
    create_pq_session
    visit dashboard_path

    expect(page).not_to have_content(uin)
    expect(page).to have_content('uin-2')
    expect(page).to have_content('uin-3')
  end
end