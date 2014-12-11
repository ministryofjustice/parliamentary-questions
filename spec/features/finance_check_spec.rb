require 'spec_helper'

feature 'Finance Check' do
  scenario "check on seen by finance to progress to uncommissioned" do
    pq = create(:question)
    sign_in
    visit "/pqs/#{pq.uin}"
    click_link 'Finance check'
    check 'Seen by finance'
    click_button 'Save'
    expect(page).to have_content 'uncommissioned'
  end

  scenario "unchecking seen by finance to reverse back to with finance" do
    pq = create(:question_uncommissioned)
    sign_in
    visit "/pqs/#{pq.uin}"
    click_link 'Finance check'
    uncheck 'Seen by finance'
    click_button 'Save'
    expect(page).to have_content 'with finance'
  end
end
