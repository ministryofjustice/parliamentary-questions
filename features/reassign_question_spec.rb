require 'feature_helper'

feature 'Parli-branch re-assigns a question', js: true, suspend_cleaner: true do
  include Features::PqHelpers

  let(:ao1)      { ActionOfficer.find_by(email: 'ao1@pq.com') }
  let(:ao2)      { ActionOfficer.find_by(email: 'ao2@pq.com') }
  let(:minister) { Minister.first                             }

  before(:all) do
    DBHelpers.load_feature_fixtures
    clear_sent_mail
    @pq, _ =  PQA::QuestionLoader.new.load_and_import(2)

  end

  after(:all) do
    DatabaseCleaner.clean
  end

  scenario 'Parli-branch assigns question to an action officer' do
    create_pq_session
    commission_question(@pq.uin, [ao1], minister)
  end

  scenario 'Parli-branch cannot re-assign before AO accepts question' do
    create_pq_session
    visit pq_path(@pq.uin)
    click_on "PQ commission"

    expect(page.title).to have_text("PQ #{@pq.uin}")
    expect(page).not_to have_content('Reassign action officer')
    expect(page).not_to have_content('Action officer(s)')
  end

  scenario 'Action officer receive notification and accepts question' do
    accept_assignment(ao1)
  end

  scenario 'Parli-branch re-assigns question to another action officer' do
    create_pq_session
    visit pq_path(@pq.uin)
    click_on "PQ commission"

    expect(page).to have_content(ao1.email)
    expect(page).not_to have_content(ao2.email)

    click_on 'Manually reject this action officer'

    commission_question(@pq.uin, [ao2], minister)
    accept_assignment(ao2)

    visit pq_path(@pq.uin)
    click_on "PQ commission"

    expect(page).not_to have_content(ao1.email)
    expect(page).to have_content(ao2.email)
  end

end
