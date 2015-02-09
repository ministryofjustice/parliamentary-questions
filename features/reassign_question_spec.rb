require 'feature_helper'

feature 'Reassign question' do
  include FactoryGirl::Syntax::Methods

  scenario 'assign question to another action officer' do
    question = create(:draft_pending_pq)
    old_action_officer = question.action_officers.first
    new_action_officer = create(:action_officer)
    create_pq_session
    visit "/pqs/#{question.uin}"
    select new_action_officer.name, from: 'Reassign action officer'
    click_button 'Save'
    expect(page).to have_content(new_action_officer.email)
    expect(page).not_to have_content(old_action_officer.email)
  end

  scenario 'reassignment not shown when past no response' do
    question = create(:not_responded_pq)
    create_pq_session
    visit "/pqs/#{question.uin}"
    expect(page).not_to have_content('Reassign action officer')
    expect(page).not_to have_content('Action officer(s)')
  end
end
