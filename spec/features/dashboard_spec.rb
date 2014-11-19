require 'spec_helper'

feature 'Visit the dashboard an show the questions for the day' do
  scenario "can view the questions tabled for today" do
    pq = create(:pq)
    sign_in
    visit '/dashboard'
    expect(page).to have_content(pq.uin)
  end
end
