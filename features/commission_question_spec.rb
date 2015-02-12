require 'feature_helper'

feature 'Commissioning questions', suspend_cleaner: true do

  let(:ao)        { ActionOfficer.find_by(email: 'ao1@pq.com') }
  let(:minister)  { Minister.first                             }

  before(:all) do
   @pq , _ =  PQA::QuestionLoader.new.load_and_import(1)

   create_finance_session
   check "pq[1][finance_interest]"
   click_link_or_button 'btn_finance_visibility'
   # q = Pq.first
   # q.seen_by_finance   = true
   # q.internal_deadline = Date.today + 1.day
   # q.internal_deadline = Date.today + 2.day
   # PQProgressChangerService.new.update_progress(q)
   # q.save
  end

  scenario 'Parli-branch member allocates a question to an AO', js: true do
    create_pq_session
    visit dashboard_path
    select minister.name, from: 'Answering minister'
    select ao.name, from: 'Action officer(s)'

    binding.pry
    fill_in "Internal deadline", with: (Date.today + 1.days).strftime("D/M/Y")
    save_and_open_page
    click_on 'Commission'

    expect(page).to have_content("#{@pq.uin} commissioned successfully")
  end

  scenario 'AO received email notification of assigned question with a link' do
    mail = ActionMailer::Base.deliveries.last

    expect(mail.to).to include ao.email
    expect(mail.text_part.body).to include "You have been allocated PQ #{@pq.uin}"
  end

  xscenario 'Following the link after 3 days have passed shows error page' do
    # Trigger assignment email postdated 3 days
    # Extract link
    # Visit lin
    # Expect unauthorised message on the page
  end
end