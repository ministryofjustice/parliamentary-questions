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


  scenario 'Acceptance of a question by an AO should show in report as draft pending' do
    pq = Pq.first
    progress_pq_to_draft_pending(pq)
    visit reports_ministers_by_progress_path
    el = find_table_element_by_minister_and_progress(minister, draft_pending_progress)
    expect(el.text).to eq '1'
  end

  scenario 'Setting date for answer to parliament should show in report as With POD' do
    pq = Pq.all[1]
    progress_pq_to_draft_pending(pq)
    progress_pq_from_draft_pending_to_with_pod(pq)
    visit reports_ministers_by_progress_path
    el = find_table_element_by_minister_and_progress(minister, with_pod_progress)
    expect(el.text).to eq '1'
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



