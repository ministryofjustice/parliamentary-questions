require 'feature_helper'

feature 'Commissioning questions', suspend_cleaner: true do
  let(:ao)        { ActionOfficer.find_by(email: 'ao1@pq.com') }
  let(:minister)  { Minister.first                             }

  before(:all) do
    @pq, _ =  PQA::QuestionLoader.new.load_and_import(1)

    create_finance_session
    check "pq[1][finance_interest]"
    click_link_or_button 'btn_finance_visibility'
  end

  scenario 'Parli-branch member allocates a question to an AO', js: true do
    create_pq_session
    visit dashboard_path

    within("*[data-pquin='#{@pq.uin}']") do
      select minister.name, from: 'Answering minister'
      select ao.name, from: 'Action officer(s)'
      find("input.internal-deadline").set Date.tomorrow.strftime('%d/%m/%Y')
    end

    click_on 'Commission'
    expect(page).to have_content("#{@pq.uin} commissioned successfully")
  end

  scenario 'AO received email notification of assigned question with a link' do
    aa_mail = ActionMailer::Base.deliveries.first
    expect(aa_mail.to).to include ao.email
    expect(aa_mail.text_part.body).to include "You have been allocated PQ #{@pq.uin}"
  end

  scenario 'Following the link after 3 days have passed shows error page'
end
