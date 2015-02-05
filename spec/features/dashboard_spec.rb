require 'spec_helper'

feature 'Visit the dashboard an show the questions for the day' do
  scenario "can view the questions tabled for today", js: true do
    require 'pry'; binding.pry
    pq = create(:pq)
    visit '/dashboard'
    expect(page).to have_content(pq.uin)
  end
end
