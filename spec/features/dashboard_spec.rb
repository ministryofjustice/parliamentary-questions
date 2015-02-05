require 'spec_helper'


feature 'Visit the dashboard an show the questions for the day' do
  before(:all) {
    create_pq_session
  }

  scenario "can view the questions tabled for today", js: true do
    pq = create(:pq)
    visit '/dashboard'
    expect(page).to have_content(pq.uin)
  end
end
