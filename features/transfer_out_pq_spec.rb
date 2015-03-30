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

  def transfer_out_pq(uin, date = nil)
    create_pq_session
    visit dashboard_path
    click_on uin
    click_on "PQ commission"

    find("select[name = 'pq[transfer_out_ogd_id]']")
      .find(:xpath, "option[2]")
      .select_option

    find('#transfer_out_date').set(date || Date.today.strftime('%d/%m/%Y'))
    click_on 'Save'
  end

  scenario 'Parli-branch should not be able to update a question with incorrect inputs' do
    transfer_out_pq(uin, 'a' * 51)

    expect(page.title).to have_text("PQ #{uin}")
    expect(page).to have_content('Invalid date input')
    expect(page).not_to have_content('Successfully updated')
  end

  scenario 'Parli branch should be able to transfer out a PQ' do
    transfer_out_pq(uin)
    expect(page.title).to have_text("PQ #{uin}")
    expect(page).to have_content('Successfully updated')
  end

  scenario 'The transferred out PQ should have label set to "Transferred out"' do
    create_pq_session
    visit pq_path(uin)

    within('#pq-details-progress') do
      expect(page.title).to have_text("PQ #{uin}")
      expect(page).to have_content('Transferred out')
    end
  end

  scenario 'The transferred out PQ should not be visible in the dashboard view' do
    create_pq_session
    visit dashboard_path

    expect(page).not_to have_content(uin)
    Pq.order(:uin).drop(1).each do |pq|
      expect(page.title).to have_text("Dashboard")
      expect(page).to have_content(pq.uin)
    end
  end
end
