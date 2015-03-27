require 'feature_helper'

feature 'Minister Report', js: true, suspend_cleaner: true do
  include Features::PqHelpers

  before(:all) do
    DBHelpers.load_feature_fixtures
    PQA::QuestionLoader.new.load_and_import(10)
    clear_sent_mail
  end

  let(:action_officer)          { ActionOfficer.first }
  let(:minister)                { Minister.find_by_name('Chris Grayling') }
  let(:policy_minister)         { Minister.find_by_name('Damian Green (MP)') }
  let(:draft_pending_progress)  { Progress.find_by_name('Draft Pending') }


  scenario 'Acceptance of a question by an AO should show in report as draft pending' do
    pq = Pq.first
    progress_pq_to_draft_pending(pq)
    visit reports_ministers_by_progress_path
    el = find_table_element_by_minister_and_progress(minister, draft_pending_progress)
    expect(el.text).to eq '1'
  end


end 


def progress_pq_to_draft_pending(pq)
  set_seen_by_finance
  commission_question(pq.uin, [action_officer], minister, policy_minister)
  accept_assignment(action_officer)
end

def find_table_element_by_minister_and_progress(minister, progress)
  selector = %Q<a[href='/reports/filter_all?minister_id=#{minister.id}&progress_id=#{progress.id}']>
  find(selector)
end



