require 'spec_helper'

feature 'Visit the dashboard' do
  scenario "can view the questions tabled for today" do
    pq = create(:question)
    sign_in
    visit '/dashboard'
    expect(page).to have_content(pq.uin)
  end
end
