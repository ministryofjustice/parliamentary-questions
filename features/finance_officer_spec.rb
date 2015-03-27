require 'feature_helper'

feature 'Creating finance officers', js: true, suspend_cleaner: true do
  include Features::EmailHelpers

  after(:all) do
    DatabaseCleaner.clean
  end

  let(:email) { 'fo@pq.com'       }
  let(:name)  { 'finance offer 1' }
  let(:pass)  { '123456789'       }

  scenario 'Parli-branch can invite a new user to be a finance officer' do
    create_pq_session
    visit users_path
    click_on 'Invite new user'

    fill_in 'Email', with: email
    fill_in 'Name', with: name
    select 'FINANCE', from: 'Role'
    click_on 'Send an invitation'
    expect(page.title).to have_content("Users Index")
    expect(page).to have_content "An invitation email has been sent to #{email}"
  end

  scenario 'New user receives an email invitation to become a finance officer' do
    invitation = sent_mail_to(email).last

    expect(invitation.subject).to eq 'Invitation instructions'
    expect(invitation.body).to include 'You have been invited to use the PQ Tracker'
  end

  scenario 'Clicking the link allows the user to set their password' do
    invitation = sent_mail_to(email).last
    url = extract_url_like('/users/invitation/accept', invitation)

    visit url
    fill_in 'Password', with: pass
    fill_in 'Password confirmation', with: pass
    click_on 'Set my password'

    expect(page.title).to have_content("New PQs today")
    expect(page).to have_content 'Your password was set successfully. You are now signed in'
  end

  scenario 'New finance officer can login to view a list of questions' do
    visit new_user_session_path

    fill_in 'Email', with: email
    fill_in 'Password', with: pass
    click_on 'Sign in'

    expect(page.title).to have_content("New PQs today")
    expect(page).to have_content "New PQs today"
  end
end

feature 'Registering interest in PQs as a Finance Officer', js: true do
  before do
    DBHelpers.load_feature_fixtures
    @pqs = PQA::QuestionLoader.new.load_and_import(3)
    create_finance_session
  end

  scenario 'FO cannot access the dashboard page' do
    visit dashboard_path

    expect(page).to have_content(/unauthorized/i)
  end

  scenario 'FO can register interest in PQs' do
    @pqs.each do |pq|
    expect(page.title).to have_content("New PQs today")
      expect(page).to have_content(pq.text)
    end

    check 'pq[2][finance_interest]'
    click_link_or_button 'btn_finance_visibility'
    expect(page.title).to have_content("New PQs today")
    expect(page).to have_content(/successfully registered interest/i)
  end
end
