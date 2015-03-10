require 'spec_helper'

describe PQProgressChangerService do

  let(:deputy_director) { create(:deputy_director, name: 'dd name', email: 'dd@dd.gov', id: 1+rand(10))}
  let(:action_officer) { create(:action_officer, name: 'ao name 1', email: 'ao@ao.gov', deputy_director_id: deputy_director.id) }
  let(:minister_1) { create(:minister, name: 'name1') }
  let(:minister) {build(:minister)}
  let(:policy_minister) { create(:minister) }

  let(:pq_progress_changer_service) { described_class.new }

  before(:each) do
    ActionMailer::Base.deliveries = []
  end

  describe '#update_progress' do
    subject do
      pq_progress_changer_service.update_progress(pq)
      pq.progress.name
    end

    describe 'when draft_answer_received is completed' do
      before do
        pq.update(draft_answer_received: DateTime.now)
      end

      context 'for DRAFT_PENDING question' do
        let(:pq) { create(:draft_pending_pq) }
        it { is_expected.to eql(Progress.WITH_POD) }
      end

      context 'for question not DRAFT_PENDING' do
        let(:pq) { create(:not_responded_pq) }
        it { is_expected.not_to eql(Progress.WITH_POD) }
      end
    end

    describe 'when pod_query_flag is set true' do
      before do
        pq.update(pod_query_flag: true)
      end

      context 'for WITH_POD question' do
        let(:pq) { create(:with_pod_pq) }
        it { is_expected.to eql(Progress.POD_QUERY) }
      end

      context 'for question which is not WITH_POD' do
        let(:pq) { create(:draft_pending_pq) }
        it { is_expected.not_to eql(Progress.POD_QUERY) }
      end
    end

    describe 'when pod_clearance is set' do
      before do
        pq.update(pod_clearance: DateTime.now)
      end

      context 'for POD_QUERY question' do
        let(:pq) { create(:pod_query_pq) }
        it { is_expected.to eql(Progress.POD_CLEARED) }
      end

      context 'for question which is not (POD_QUERY or POD_WAITING)' do
        let(:pq) { create(:draft_pending_pq) }
        it { is_expected.not_to eql(Progress.POD_CLEARED) }
      end
    end

    describe 'when sent_to_answering_minister set' do
      before do
        pq.update(sent_to_answering_minister: DateTime.now)
      end

      context 'for POD_CLEARED question and no policy minister set' do
        let(:pq) { create(:pod_cleared_pq) }
        it { is_expected.to eql(Progress.WITH_MINISTER) }
      end

      context 'for POD_CLEARED question and policy minister set' do
        let(:pq) { create(:pod_cleared_pq, policy_minister: policy_minister) }
        it { is_expected.not_to eql(Progress.WITH_MINISTER) }
      end
    end

    describe 'when sent_to_answering_minister and sent_to_policy_minister are set' do
      before do
        pq.update(sent_to_answering_minister: DateTime.now, sent_to_policy_minister: DateTime.now)
      end

      context 'for POD_CLEARED question and policy minister set' do
        let(:pq) { create(:pod_cleared_pq, policy_minister: policy_minister) }
        it { is_expected.to eql(Progress.WITH_MINISTER) }
      end

      context 'for question which is not POD_CLEARED' do
        let(:pq) { create(:draft_pending_pq) }
        it { is_expected.not_to eql(Progress.WITH_MINISTER) }
      end
    end

    describe 'when answering_minister_query is set to true' do
      before do
        pq.update(answering_minister_query: true)
      end

      context 'for WITH_MINISTER question and no policy minister' do
        let(:pq) { pq = create(:with_minister_pq) }
        it { is_expected.to eql(Progress.MINISTERIAL_QUERY) }
      end

      context 'for WITH_MINISTER question and policy minister set' do
        let(:pq) { create(:with_minister_pq, policy_minister: policy_minister, sent_to_policy_minister: Time.now ) }
        it { is_expected.to eql(Progress.MINISTERIAL_QUERY) }
      end

      context 'for question which is not WITH_MINISTER' do
        let(:pq) { create(:with_pod_pq) }
        it { is_expected.not_to eql(Progress.MINISTERIAL_QUERY) }
      end
    end

    describe 'when policy_minister_query is set to true' do
      before do
        pq.update(policy_minister_query: true)
      end

      context 'for WITH_MINISTER question and policy minister set' do
        let(:pq) { create(:with_minister_pq, policy_minister: policy_minister, sent_to_policy_minister: Time.now ) }
        it { is_expected.to eql(Progress.MINISTERIAL_QUERY) }
      end
    end

    describe 'when cleared_by_answering_minister is set' do
      before do
        pq.update(cleared_by_answering_minister: Time.now)
      end

      context 'for MINISTER_QUERY question with no policy minister' do
        let(:pq) { create(:ministerial_query_pq) }
        it { is_expected.to eql(Progress.MINISTER_CLEARED) }
      end

      context 'for WITH_MINISTER question with no policy minister' do
        let(:pq) { create(:with_minister_pq) }
        it { is_expected.to eql(Progress.MINISTER_CLEARED) }
      end

      context 'for MINISTER_QUERY question with policy minister' do
        let(:pq) { create(:ministerial_query_pq, policy_minister: policy_minister, sent_to_policy_minister: Time.now) }
        it { is_expected.not_to eql(Progress.MINISTER_CLEARED) }
      end
    end

    describe 'when cleared_by_answering_minister and cleared_by_policy_minister are set' do
      before do
        pq.update(cleared_by_answering_minister: Time.now, cleared_by_policy_minister: Time.now)
      end

      context 'for MINISTER_QUERY question and policy minister set' do
        let(:pq) { create(:ministerial_query_pq, policy_minister: policy_minister, sent_to_policy_minister: Time.now) }
        it { is_expected.to eql(Progress.MINISTER_CLEARED) }
      end

      context 'for WITH_MINISTER question and policy minister set' do
        let(:pq) { create(:ministerial_query_pq, policy_minister: policy_minister, sent_to_policy_minister: Time.now) }
        it { is_expected.to eql(Progress.MINISTER_CLEARED) }
      end

      context 'for question which is not (WITH_MINISTER or MINISTER_QUERY)' do
        let(:pq) { create(:pod_cleared_pq) }
        it { is_expected.not_to eql(Progress.MINISTER_CLEARED) }
      end
    end

    describe 'when answer_submitted is set' do
      before do
        pq.update(answer_submitted: Time.now)
      end

      context 'for MINISTER_CLEARED question' do
        let(:pq) { create(:minister_cleared_pq) }
        it { is_expected.to eql(Progress.ANSWERED) }
      end

      context 'for question other than MINISTER_CLEARED' do
        let(:pq) { create(:ministerial_query_pq) }
        it { is_expected.not_to eql(Progress.ANSWERED) }
      end
    end

    describe 'when pq_withdrawn is set' do
      before do
        pq.update(pq_withdrawn: Time.now)
      end

      context 'for MINISTER_CLEARED question' do
        let(:pq) { create(:minister_cleared_pq) }
        it { is_expected.to eql(Progress.ANSWERED) }
      end
    end

    describe 'when all required fields for a question to be answered are set' do
      before do
        pq.update(draft_answer_received: Time.now,
                  pod_query_flag: true,
                  pod_clearance: Time.now,
                  sent_to_answering_minister: Time.now,
                  answering_minister_query: true,
                  cleared_by_answering_minister: Time.now,
                  answer_submitted: Time.now)
      end

      context 'for DRAFT_PENDING question' do
        let(:pq) { create(:draft_pending_pq) }
        it { is_expected.to eql(Progress.ANSWERED) }
      end
    end

    describe 'when transfer_out_ogd_id and transfer_out_ogd_id are set' do
      before do
        pq.update(transfer_out_ogd_id: Time.now,
                  transfer_out_date: Time.now)

      end

      context 'for any question type' do
        let(:pq) { create(:draft_pending_pq) }
        it { is_expected.to eql(Progress.TRANSFERRED_OUT) }
      end
    end

    describe 'when action officer accept status changes' do
      before { pq.action_officers_pqs.first.update(response: :awaiting) }

      let(:pq) { create(:draft_pending_pq) }
      it { is_expected.to eql(Progress.NO_RESPONSE) }
    end

    describe 'when action officer is set to rejected' do
      before do
        pq.action_officers_pqs.first.reject('Some option', 'Some reason')
      end

      let(:pq) { create(:draft_pending_pq) }
      it { is_expected.to eql(Progress.REJECTED) }
    end

    describe 'action officer accepted the question' do
      before { create(:accepted_action_officers_pq, pq: pq) }

      let(:pq) { create(:pq) }
      it { is_expected.to eql(Progress.DRAFT_PENDING) }
    end
  end
end
