require 'spec_helper'

describe PQProgressChangerService do

  let(:deputy_director) { create(:deputy_director, name: 'dd name', email: 'dd@dd.gov', id: 1+rand(10))}
  let(:action_officer) { create(:action_officer, name: 'ao name 1', email: 'ao@ao.gov', deputy_director_id: deputy_director.id) }
  let(:minister_1) { create(:minister, name: 'name1') }
  let(:minister) {build(:minister)}
  let(:policy_minister) { create(:minister) }

  let(:pq_progress_changer_service) { described_class.new }

  before(:each) do
    @pq_progress_changer_service = PQProgressChangerService.new
    @assignment_service = AssignmentService.new
    @comm_service = CommissioningService.new
    ActionMailer::Base.deliveries = []
  end

  describe '#update_progress' do
    subject do
      pq_progress_changer_service.update_progress(pq)
      # return new progress name, so it can be easily asserted
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

      context 'for question not (DRAFT_PENDING or ACCEPTED)' do
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
  end

  describe 'WITH MINISTER' do
    it 'should move the question from POD_CLEARED to WITH_MINISTER if sent_to_answering_minister completed and there is no policy minister' do
      pq = create(:pod_cleared_pq)

      pq.update(sent_to_answering_minister: DateTime.now)

      pq_progress_changer_service.update_progress(pq)

      expect(pq.progress.name).to eql(Progress.WITH_MINISTER)
    end

    it 'should move the question from POD_CLEARED to WITH_MINISTER if sent_to_answering_minister and sent_to_policy_minister is completed when policy minister is set' do
      # Fixme having policy_minister assigned doesn't change anything, the progress gets changed anyway (it only checks the dates)
      pq = create(:pod_cleared_pq, policy_minister: policy_minister)

      pq.update(sent_to_answering_minister: DateTime.now, sent_to_policy_minister: DateTime.now)

      pq_progress_changer_service.update_progress(pq)

      expect(pq.progress.name).to eql(Progress.WITH_MINISTER)
    end

    it 'should NOT move the question from POD_CLEARED to WITH_MINISTER if sent_to_answering_minister completed and sent_to_policy_minister is NOT completed when policy minister is set' do
      pq = create(:pod_cleared_pq, policy_minister: policy_minister)

      pq.update(sent_to_answering_minister: DateTime.now)

      pq_progress_changer_service.update_progress(pq)

      expect(pq.progress.name).not_to eql(Progress.WITH_MINISTER)
    end

    # Fixme this test should really either not exist or test all possible start progresses
    it 'should NOT move the question to WITH_MINISTER if the progress is not POD_CLEARED' do
      pq = create(:draft_pending_pq)

      pq.update(sent_to_answering_minister: DateTime.now, sent_to_policy_minister: DateTime.now)

      pq_progress_changer_service.update_progress(pq)

      expect(pq.progress.name).not_to eql(Progress.WITH_MINISTER)
    end
  end


  describe 'Minister Query' do
    it 'should move the question from WITH_MINISTER to MINISTER_QUERY if answering_minister_query true and there is no policy minister' do
      pq = create(:with_minister_pq)

      pq.update(answering_minister_query: true)

      pq_progress_changer_service.update_progress(pq)

      expect(pq.progress.name).to eql(Progress.MINISTERIAL_QUERY)
    end

    it 'should move the question from WITH_MINISTER to MINISTER_QUERY if policy_minister_query true when policy minister is set' do
      pq = create(:with_minister_pq, policy_minister: policy_minister, sent_to_policy_minister: Time.now )

      pq.update(policy_minister_query: true)

      pq_progress_changer_service.update_progress(pq)

      expect(pq.progress.name).to eql(Progress.MINISTERIAL_QUERY)
    end

    it 'should move the question from WITH_MINISTER to MINISTER_QUERY if answering_minister_query true when policy minister is set' do
      pq = create(:with_minister_pq, policy_minister: policy_minister, sent_to_policy_minister: Time.now )

      pq.update(answering_minister_query: true)

      pq_progress_changer_service.update_progress(pq)

      expect(pq.progress.name).to eql(Progress.MINISTERIAL_QUERY)
    end

    # Fixme this test should really either not exist or test all possible start progresses
    it 'should NOT move the question to MINISTER_QUERY if the progress is not WITH_MINISTER' do
      pq = create(:with_pod_pq)

      pq.update(answering_minister_query: true)

      pq_progress_changer_service.update_progress(pq)

      expect(pq.progress.name).not_to eql(Progress.MINISTERIAL_QUERY)
    end
  end

  describe 'Minister Cleared' do
    it 'should move the question from MINISTER_QUERY to MINISTER_CLEARED if cleared_by_answering_minister completed and there is no policy minister' do
      pq = create(:minister_query_pq)

      pq.update(cleared_by_answering_minister: Time.now)

      pq_progress_changer_service.update_progress(pq)

      expect(pq.progress.name).to eql(Progress.MINISTER_CLEARED)
    end

    it 'should move the question from WITH_MINISTER to MINISTER_CLEARED if cleared_by_answering_minister completed and there is no policy minister' do
      pq = create(:with_minister_pq)

      pq.update(cleared_by_answering_minister: Time.now)

      pq_progress_changer_service.update_progress(pq)

      expect(pq.progress.name).to eql(Progress.MINISTER_CLEARED)
    end

    it 'should move the question from MINISTER_QUERY to MINISTER_CLEARED if cleared_by_answering_minister and cleared_by_policy_minister is completed when policy minister is set' do
      pq = create(:minister_query_pq, policy_minister: policy_minister, sent_to_policy_minister: Time.now)

      pq.update(cleared_by_answering_minister: Time.now, cleared_by_policy_minister: Time.now)

      pq_progress_changer_service.update_progress(pq)

      expect(pq.progress.name).to eql(Progress.MINISTER_CLEARED)
    end

    it 'should move the question from WITH_MINISTER to MINISTER_CLEARED if cleared_by_answering_minister and cleared_by_policy_minister is completed when policy minister is set' do
      pq = create(:with_minister_pq, policy_minister: policy_minister, sent_to_policy_minister: Time.now)

      pq.update(cleared_by_answering_minister: Time.now, cleared_by_policy_minister: Time.now)

      pq_progress_changer_service.update_progress(pq)

      expect(pq.progress.name).to eql(Progress.MINISTER_CLEARED)
    end

    it 'should NOT move the question from MINISTER_QUERY to MINISTER_CLEARED if cleared_by_answering_minister completed and cleared_by_policy_minister is NOT completed when policy minister is set' do
      pq = create(:minister_query_pq, policy_minister: policy_minister, sent_to_policy_minister: Time.now)

      pq.update(cleared_by_answering_minister: Time.now)

      pq_progress_changer_service.update_progress(pq)

      expect(pq.progress.name).not_to eql(Progress.MINISTER_CLEARED)
    end

    # Fixme this test should really either not exist or test all possible start progresses
    it 'should NOT move the question to MINISTER_CLEARED if the progress is not MINISTER_QUERY or MINISTER_WAITING' do
      pq = create(:pod_cleared_pq)

      pq.update(cleared_by_policy_minister: Time.now)

      pq_progress_changer_service.update_progress(pq)

      expect(pq.progress.name).not_to eql(Progress.MINISTER_CLEARED)
    end
  end


  #  *Remove from dashboard - if - 'answer_submitted || pq_withdrawn’ is completed
  describe 'Answered (remove from dashboard)' do
    it 'should move the question from MINISTER_CLEARED to ANSWERED if answer_submitted completed' do
      pq = create(:minister_cleared_pq)

      pq.update(answer_submitted: Time.now)

      pq_progress_changer_service.update_progress(pq)

      expect(pq.progress.name).to eql(Progress.ANSWERED)
    end

    it 'should move the question from MINISTER_CLEARED to ANSWERED if pq_withdrawn set' do
      pq = create(:minister_cleared_pq)

      pq.update(pq_withdrawn: Time.now)

      pq_progress_changer_service.update_progress(pq)

      expect(pq.progress.name).to eql(Progress.ANSWERED)
    end

    # Fixme this test doesn't seem to test any functionality from the progress changes
    it 'should not move the question from MINISTER_CLEARED to ANSWERED if pq_withdrawn or answer_submitted not set ' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',
                  progress_id: Progress.pod_query.id, policy_minister_id: minister_1.id)

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)

      pq.update(draft_answer_received: DateTime.now,
                pod_query_flag: true,
                pod_clearance: DateTime.now,
                sent_to_answering_minister: DateTime.now,
                sent_to_policy_minister: DateTime.now,
                answering_minister_query: true,
                cleared_by_policy_minister: DateTime.now,
                cleared_by_answering_minister: DateTime.now,
                progress_id: Progress.minister_cleared.id)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.MINISTER_CLEARED)

    end

    # Fixme this test should really either not exist or test all possible start progresses
    it 'should NOT move the question to ANSWERED if the progress is not MINISTER_CLEARED' do
      pq = create(:minister_query_pq)

      pq.update(answer_submitted: Time.now)

      pq_progress_changer_service.update_progress(pq)

      expect(pq.progress.name).not_to eql(Progress.ANSWERED)
    end
  end


  describe 'From DRAFT_PENDING to ANSWERED' do
    it 'should move the question from DRAFT_PENDING to ANSWERED if all the data necessary is set' do
      pq = create(:draft_pending_pq)

      pq.update(draft_answer_received: Time.now,
                pod_query_flag: true,
                pod_clearance: Time.now,
                sent_to_answering_minister: Time.now,
                answering_minister_query: true,
                cleared_by_answering_minister: Time.now,
                answer_submitted: Time.now)

      pq_progress_changer_service.update_progress(pq)

      expect(pq.progress.name).to eql(Progress.ANSWERED)
    end
  end


  describe 'TRANSFERRED_OUT' do
    # Fixme should this test all possible initial statuses?
    it 'should move from any other status when relevant data is set' do
      pq = create(:draft_pending_pq)

      pq.update(transfer_out_ogd_id: Time.now,
                transfer_out_date: Time.now)

      pq_progress_changer_service.update_progress(pq)

      expect(pq.progress.name).to eql(Progress.TRANSFERRED_OUT)
    end
  end

  describe 'COMMISSIONED' do
    it 'should move from any other status when relevant data is set' do
      @comm_service = CommissioningService.new
      ActionMailer::Base.deliveries = []

      uin = 'TEST1'
      #pq = create(:Pq, uin: uin, question: 'test question?', progress_id: Progress.draft_pending.id)
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',  progress_id: Progress.draft_pending.id )

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)

      pq.progress.name.should eq(Progress.NO_RESPONSE)
    end

    it 'should not move to Commissioned if accepted' do
      @assignment_service = AssignmentService.new
      @comm_service = CommissioningService.new
      ActionMailer::Base.deliveries = []

      uin = 'TEST1'
      #pq = create(:Pq, uin: uin, question: 'test question?', progress_id: Progress.draft_pending.id)
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',  progress_id: Progress.draft_pending.id )

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)

      pq.progress.name.should_not eq(Progress.NO_RESPONSE)
      pq.progress.name.should eq(Progress.ACCEPTED)

    end
  end

  describe 'REJECTED' do
    it 'should move to Rejected if all the relevant data is present' do
      @assignment_service = AssignmentService.new
      @comm_service = CommissioningService.new
      ActionMailer::Base.deliveries = []

      uin = 'TEST1'
      #pq = create(:Pq, uin: uin, question: 'test question?', progress_id: Progress.draft_pending.id)
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',  progress_id: Progress.draft_pending.id )

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)

      response = double('response')
      allow(response).to receive(:reason) { 'Some reason' }
      allow(response).to receive(:reason_option) { 'reason option' }
      @assignment_service.reject(assignment, response)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)

      pq.progress.name.should_not eq(Progress.NO_RESPONSE)
      pq.progress.name.should eq(Progress.REJECTED)
    end
  end
  describe 'ACCEPTED' do
    it 'should move to accepted' do
      @assignment_service = AssignmentService.new
      @comm_service = CommissioningService.new
      ActionMailer::Base.deliveries = []

      uin = 'TEST1'
      #pq = create(:Pq, uin: uin, question: 'test question?', progress_id: Progress.draft_pending.id)
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',  progress_id: Progress.draft_pending.id )

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)

      pq.progress.name.should eq(Progress.ACCEPTED)

    end
  end
  describe 'DRAFT_PENDING' do
    it 'should move to draft pending when the accepted date is before the beginning of today' do
      @assignment_service = AssignmentService.new
      @comm_service = CommissioningService.new
      ActionMailer::Base.deliveries = []

      uin = 'Garblearblefarble'
      #pq = create(:Pq, uin: uin, question: 'test question?', progress_id: Progress.draft_pending.id)
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',  progress_id: Progress.draft_pending.id )
      yesterday = DateTime.now - 1.day
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id, accept: true, reject: false, updated_at: yesterday)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)
      assignment.update(updated_at: yesterday)

      @pq_progress_changer_service.update_progress(pq)


#      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.DRAFT_PENDING)

    end

  end
end