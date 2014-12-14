require 'spec_helper'

feature 'Commissioning' do
  scenario "commission a new question" do
    question = create(:question_uncommissioned)
    action_officer = create(:action_officer)
    minister = create(:minister)
    sign_in
    visit '/dashboard'
    select minister.name, from: 'commission_form_minister_id'
    select action_officer.name, from: "action_officers_pqs_action_officer_id_#{question.id}"
    fill_in "pq_date_for_answer-#{question.id}", with: 2.days.from_now.to_s
    fill_in "pq_internal_deadline-#{question.id}", with: Date.tomorrow.to_s

    click_button 'Commission'
    visit '/dashboard'

    expect(page).to have_content 'Awaiting response'
  end
end

