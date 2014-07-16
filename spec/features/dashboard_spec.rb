require 'spec_helper'

feature 'Visit the dashboard an show the questions for the day' do
  let(:user) { create(:user, name: 'admin', email:'admin@admin.com', password: 'password123') }
  progress_seed

  context 'as pq user' do
    before do
      visit '/dashboard'
      sign_in user
    end

    context 'view' do
      scenario "can view the questions tabled for today" do
        visit '/dashboard'
        expect(page).to have_content('PQ Tool')
      end
    end

  end
end
