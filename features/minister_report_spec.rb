require 'feature_helper'

feature 'Minister Report', js: true, suspend_cleaner: true do
  include Features::PqHelpers

  before(:all) do
    DBHelpers.load_feature_fixtures
    PQA::QuestionLoader.new.load_and_import(10)
  end

  before(:each) do
    clear_sent_mail
    visit destroy_user_session_path
    create_pq_session
  end

  let(:action_officer)          { ActionOfficer.first }
  let(:minister)                { Minister.find_by_name('Chris Grayling') }
  let(:policy_minister)         { Minister.find_by_name('Damian Green (MP)') }
  let(:draft_pending_progress)  { Progress.find_by_name('Draft Pending') }
  let(:with_pod_progress)       { Progress.find_by_name('With POD') }
  let(:pod_query)               { Progress.find_by_name('POD Query') }
  let(:pod_cleared)             { Progress.find_by_name('POD Cleared') }
  let(:with_minister)           { Progress.find_by_name('With Minister') }


  scenario 'Acceptance of a question by an AO should show in report as draft pending' do
    pq = Pq.first
    progress_pq_to_draft_pending(pq)
    expect_ministers_report_to_have(minister, draft_pending_progress, '1')
  end

  scenario 'Setting date for answer to parliament should show in report as With POD' do
    pq = Pq.all[1]
    progress_pq_to_draft_pending(pq)
    progress_pq_from_draft_pending_to_with_pod(pq)
    expect_ministers_report_to_have(minister, with_pod_progress, '1')
  end


  scenario 'setting pod query flag should show in report as POD query' do
    pq = Pq.all[2]
    progress_pq_to_draft_pending(pq)
    progress_pq_from_draft_pending_to_with_pod(pq)
    progress_pq_from_with_pod_to_pod_query(pq)
    expect_ministers_report_to_have(minister, pod_query, '1')
  end

  scenario 'setting pod_cleared on with pod and pod query should set both to pod cleared' do
    pq3 = Pq.all[3]
    pq4 = Pq.all[4]
    
    progress_pq_to_draft_pending(pq3)
    progress_pq_from_draft_pending_to_with_pod(pq3)
    progress_pq_from_with_pod_to_pod_query(pq3)
    progress_pq_to_pod_cleared(pq3)

    clear_sent_mail
    progress_pq_to_draft_pending(pq4)
    progress_pq_from_draft_pending_to_with_pod(pq4)
    progress_pq_to_pod_cleared(pq4)

    expect_ministers_report_to_have(minister, pod_cleared, '2')
  end


  scenario 'setting sent_to_answering_and_policy_ministers whould show in report as with minister' do
    pq = Pq.all[5]
    progress_pq_to_draft_pending(pq)
    progress_pq_from_draft_pending_to_with_pod(pq)
    progress_pq_to_pod_cleared(pq)
    progress_pq_from_pod_cleared_to_with_minister(pq)
    expect_ministers_report_to_have(minister, with_minister, '1')
  end

end 


def progress_pq_from_pod_cleared_to_with_minister(pq)
  visit pq_path(pq)
  in_pq_detail(pq.uin, 'Minister check')  do
    fillin_date('#sent_to_answering_minister') 
    fillin_date('#sent_to_policy_minister')
    click_on 'Save'
  end
end


def progress_pq_to_pod_cleared(pq)
  visit pq_path(pq)
  in_pq_detail(pq.uin, 'POD check')  do
    fillin_date('#pod_clearance') 
    click_on 'Save'
  end
end


def expect_ministers_report_to_have(minister, progress, expected_text)
  visit reports_ministers_by_progress_path
  el = find_table_element_by_minister_and_progress(minister, progress)
  expect(el.text).to eq expected_text
end



def progress_pq_from_with_pod_to_pod_query(pq)
  visit pq_path(pq)
  in_pq_detail(pq.uin, 'POD check')  do
    check 'POD query flag'
    click_on 'Save'
  end
end


def progress_pq_to_draft_pending(pq)
  set_seen_by_finance_check_box(pq)
  commission_question(pq.uin, [action_officer], minister, policy_minister)
  accept_assignment(action_officer)
end


def progress_pq_from_draft_pending_to_with_pod(pq)
  visit pq_path(pq)
  in_pq_detail(pq.uin, "PQ draft")       { fillin_date('#draft_answer_received') }
end



def find_table_element_by_minister_and_progress(minister, progress)
  selector = %Q<a[href='/reports/filter_all?minister_id=#{minister.id}&progress_id=#{progress.id}']>
  find(selector)
end


def set_seen_by_finance_check_box(pq)
  visit pq_path(pq)
  in_pq_detail(pq.uin, 'Finance check')  do
    check 'pq_seen_by_finance'
    click_on 'Save'
  end
end



