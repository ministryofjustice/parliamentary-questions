require 'feature_helper'

feature 'Parli-branch sends reminder email to action officer', js: true, suspend_cleaner: true do
  include Features::PqHelpers

  let(:ao1)      { ActionOfficer.find_by(email: 'ao1@pq.com') }
  let(:minister) { Minister.first                             }

  before(:all) do
    DBHelpers.load_feature_fixtures
    clear_sent_mail
    @pq, _ =  PQA::QuestionLoader.new.load_and_import(2)
    set_seen_by_finance
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  scenario "PB commissions a question and sends 2 reminder emails" do
    create_pq_session
    commission_question(@pq.uin, [ao1], minister)
    visit dashboard_path

    within_pq(@pq.uin) do
      (1..2).each do |n|
        find('.ao-reminder-link').click
        sleep 0.5
        visit dashboard_path
        expect(page.title).to have_content("Dashboard")
        expect(page).to have_text("Send reminder (#{n})")
      end
    end
  end

  scenario "AO receives two reminder emails" do
    subjects = sent_mail_to(ao1.email).map(&:subject)
    expect(subjects.grep(/you need to accept or reject/i).size).to eq(2)
  end
end
