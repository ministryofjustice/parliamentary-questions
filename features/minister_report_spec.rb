require 'feature_helper'

feature 'Minister Report', js: true, suspend_cleaner: true do
  include Features::PqHelpers
  include Features::ReportSpecHelpers

  before(:all) do
    DBHelpers.load_feature_fixtures
    PQA::QuestionLoader.new.load_and_import(10)
    @pqs = Pq.all
  end

  before(:each) do
    clear_sent_mail
    visit destroy_user_session_path
    create_pq_session
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  let(:action_officer)          { ActionOfficer.first }
  let(:minister)                { Minister.find_by_name('Chris Grayling') }
  let(:policy_minister)         { Minister.find_by_name('Damian Green (MP)') }
  let(:draft_pending_progress)  { Progress.find_by_name('Draft Pending') }
  let(:with_pod_progress)       { Progress.find_by_name('With POD') }
  let(:pod_query)               { Progress.find_by_name('POD Query') }
  let(:pod_cleared)             { Progress.find_by_name('POD Cleared') }
  let(:with_minister)           { Progress.find_by_name('With Minister') }
  let(:ministerial_query)       { Progress.find_by_name('Ministerial Query') }
  let(:minister_cleared)        { Progress.find_by_name('Minister Cleared') }


  scenario 'Acceptance of a question by an AO should show in report as draft pending' do
    create_draft_pending_pq(@pqs.first)
    expect_ministers_report_to_have(minister, draft_pending_progress, '1')
  end

  scenario 'Setting date for answer to parliament should show in report as With POD' do
    create_with_pod_pq(@pqs[1])
    expect_ministers_report_to_have(minister, with_pod_progress, '1')
  end

  scenario 'setting pod query flag should show in report as POD query' do
    create_pod_query_pq(@pqs[2])
    expect_ministers_report_to_have(minister, pod_query, '1')
  end

  scenario 'setting pod_cleared on with pod and pod query should set both to pod cleared' do
    create_pod_cleared_pq_via_pod_query(@pqs[3])
    clear_sent_mail
    create_pod_cleared_pq(@pqs[4])
    expect_ministers_report_to_have(minister, pod_cleared, '2')
  end

  scenario 'setting sent_to_answering_and_policy_ministers whould show in report as with minister' do
    create_with_minister_pq(@pqs[5])
    expect_ministers_report_to_have(minister, with_minister, '1')
  end

  scenario 'setting answering minister query and policy minister query shows in reports as minister query' do
    create_answering_minister_query(@pqs[6])
    clear_sent_mail
    create_policy_minister_query(@pqs[7])
    expect_ministers_report_to_have(minister, ministerial_query, '2')
  end

  scenario 'setting cleared by answering minister should show in report as minister cleared' do
    create_minister_cleared_pq(@pqs[8])
    expect_ministers_report_to_have(minister, minister_cleared, '1')
  end

end 






