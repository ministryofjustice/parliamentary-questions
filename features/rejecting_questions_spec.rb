require 'feature_helper'

feature 'Rejecting questions', js: true, suspend_cleaner: true do
  include Features::EmailHelpers

  before(:all) do
    clear_sent_mail
    @pq, _ =  PQA::QuestionLoader.new.load_and_import(2)
   
    # Ensure questions are seen by finance
    create_finance_session
    click_link_or_button 'btn_finance_visibility'
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  let(:ao1)        { ActionOfficer.find_by(email: 'ao1@pq.com') }
  let(:ao2)        { ActionOfficer.find_by(email: 'ao2@pq.com') }
  let(:minister)   { Minister.first                             }

  scenario 'Parli-branch member allocates a question to selected AOs' do
    create_pq_session
    visit dashboard_path

    within("*[data-pquin='#{@pq.uin}']") do
      select minister.name, from: 'Answering minister'
      select ao1.name, from: 'Action officer(s)'
      select ao2.name, from: 'Action officer(s)'
      find("input.internal-deadline").set Date.tomorrow.strftime('%d/%m/%Y')
      click_on 'Commission'
    end

    expect(page).to have_content("#{@pq.uin} commissioned successfully")
  end

  scenario 'Following the email link should let an AO reject the question' do
    url = extract_url_like('/assignment', sent_mail.first)
    visit url
    choose 'Reject'
    binding.pry
    select("I think it is for another department in the MoJ",
      from: "Please select one of the reasons to reject the question")
    click_on 'Save Response'
    
    expect(page).to have_content(/thank you for your response/i)
  end

  xscenario 'Parli-branch should see which AOs have rejected the question' do
    create_pq_session
    visit dashboard_path
    # Expect to see that AO1 has rejected the question
    # Expect to see the reason for the rejection
  end

  xscenario 'The question status should remain no response' do
    create_pq_session
    visit dashboard_path
    # Expect to see that question status is no repsonse
  end

  xscenario 'If an AO is the last to reject a question, the status should change to rejected' do
    # AO2 visits link
    # Reject the question
    # Create PQ session
    # Go to dashboard
    # Expect to see question has been rejected by all the AOs
    # Expect to see question as rejected
  end
end