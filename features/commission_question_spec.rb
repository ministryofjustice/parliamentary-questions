require 'feature_helper'

feature 'Commissioning questions', js: true, suspend_cleaner: true do
  let(:ao)        { ActionOfficer.find_by(email: 'ao1@pq.com') }
  let(:minister)  { Minister.first                             }

  before(:all) do
    @pq, _ =  PQA::QuestionLoader.new.load_and_import(2)

    create_finance_session
    check "pq[1][finance_interest]"
    click_link_or_button 'btn_finance_visibility'
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  scenario 'Parli-branch member allocates a question to an AO' do
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
    ao_mail = sent_mail.first
    expect(ao_mail.to).to include ao.email
    expect(ao_mail.text_part.body).to include "You have been allocated PQ #{@pq.uin}"
  end

  scenario 'Following the link lets the AO accept or reject the question' do
    url = extract_url_like('/assignment', sent_mail.first)
    visit url
    choose 'Accept'
    click_on 'Save Response'

    expect(page).to have_content(/thank you for your response/i)
    expect(page).to have_content("PQ #{@pq.uin}")
  end

  scenario 'Following the link after 3 days have passed shows error page' do
    form_params = {
      pq_id: Pq.last.id,
      minister_id: minister.id,
      action_officer_id: [ao.id],
      date_for_answer: Date.tomorrow,
      internal_deadline: Date.today
    }
    form = CommissionForm.new(form_params) 
    CommissioningService.new(nil, Date.today - 4.days).commission(form)
    # Retrieve the AO email, ignore the DD email
    _, ao_mail = sent_mail.reverse.take(2)
    url = extract_url_like('/assignment', ao_mail)
    visit url

    expect(page).to have_content(/you don't have permission to see the page/i)
  end
end
