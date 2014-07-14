require 'spec_helper'

describe 'PQProgressChangerService' do

  let(:action_officer) { create(:action_officer, name: 'ao name 1', email: 'ao@ao.gov') }
  let(:minister_1) { create(:minister, name: 'name1', email: 'test1@tesk.uk') }
  progress_seed

  before(:each) do
    @pq_progress_changer_service = PQProgressChangerService.new
  end


  describe 'POD Waiting' do
    it 'should move the question from DRAFT_PENDING to POD_WAITING if draft_answer_received is completed' do
      uin = 'TEST1'
      pq = create(:PQ, uin: uin, question: 'test question?', progress_id: Progress.draft_pending.id)
      pq_before = pq.dup
      pq.update(draft_answer_received: DateTime.now)

      @pq_progress_changer_service.update_progress(pq_before, pq)

      pq = PQ.find_by(uin: uin)
      pq.progress.name.should eq(Progress.POD_WAITING)
    end

    it 'should NOT move the question to POD_WAITING if the progress is not DRAFT_PENDING' do
      uin = 'TEST1'
      pq = create(:PQ, uin: uin, question: 'test question?', progress_id: Progress.allocated_accepted.id)
      pq_before = pq.dup
      pq.update(draft_answer_received: DateTime.now)

      @pq_progress_changer_service.update_progress(pq_before, pq)

      pq = PQ.find_by(uin: uin)
      pq.progress.name.should eq(Progress.ALLOCATED_ACCEPTED)
    end
  end


  describe 'POD Query' do
    it 'should move the question from POD_WAITING to POD_QUERY if pod_query_flag is true' do
      uin = 'TEST1'
      pq = create(:PQ, uin: uin, question: 'test question?', progress_id: Progress.pod_waiting.id)
      pq_before = pq.dup
      pq.update(pod_query_flag: true)

      @pq_progress_changer_service.update_progress(pq_before, pq)

      pq = PQ.find_by(uin: uin)
      pq.progress.name.should eq(Progress.POD_QUERY)
    end

    it 'should NOT move the question to POD_QUERY if the progress is not POD_WAITING' do
      uin = 'TEST1'
      pq = create(:PQ, uin: uin, question: 'test question?', progress_id: Progress.draft_pending.id)
      pq_before = pq.dup
      pq.update(pod_query_flag: true)

      @pq_progress_changer_service.update_progress(pq_before, pq)

      pq = PQ.find_by(uin: uin)
      pq.progress.name.should eq(Progress.DRAFT_PENDING)
    end
  end


  describe 'POD Cleared' do
    it 'should move the question from POD_WAITING to POD_CLEARED if pod_clearance completed' do
      uin = 'TEST1'
      pq = create(:PQ, uin: uin, question: 'test question?', progress_id: Progress.pod_waiting.id)
      pq_before = pq.dup
      pq.update(pod_clearance: DateTime.now)

      @pq_progress_changer_service.update_progress(pq_before, pq)

      pq = PQ.find_by(uin: uin)
      pq.progress.name.should eq(Progress.POD_CLEARED)
    end

    it 'should move the question from POD_QUERY to POD_CLEARED if pod_clearance completed' do
      uin = 'TEST1'
      pq = create(:PQ, uin: uin, question: 'test question?', progress_id: Progress.pod_query.id)
      pq_before = pq.dup
      pq.update(pod_clearance: DateTime.now)

      @pq_progress_changer_service.update_progress(pq_before, pq)

      pq = PQ.find_by(uin: uin)
      pq.progress.name.should eq(Progress.POD_CLEARED)
    end


    it 'should NOT move the question to POD_CLEARED if the progress is not POD_QUERY or POD_WAITING' do
      uin = 'TEST1'
      pq = create(:PQ, uin: uin, question: 'test question?', progress_id: Progress.draft_pending.id)
      pq_before = pq.dup
      pq.update(pod_clearance: DateTime.now)

      @pq_progress_changer_service.update_progress(pq_before, pq)

      pq = PQ.find_by(uin: uin)
      pq.progress.name.should eq(Progress.DRAFT_PENDING)
    end
  end


  describe 'Minister Waiting' do
    it 'should move the question from POD_CLEARED to MINISTER_WAITING if sent_to_answering_minister completed and there is no policy minister' do
      uin = 'TEST1'
      pq = create(:PQ, uin: uin, question: 'test question?', progress_id: Progress.pod_cleared.id)
      pq_before = pq.dup
      pq.update(sent_to_answering_minister: DateTime.now)

      @pq_progress_changer_service.update_progress(pq_before, pq)

      pq = PQ.find_by(uin: uin)
      pq.progress.name.should eq(Progress.MINISTER_WAITING)
    end

    it 'should move the question from POD_CLEARED to MINISTER_WAITING if sent_to_answering_minister and sent_to_policy_minister is completed when policy minister is set' do
      uin = 'TEST1'
      pq = create(:PQ, uin: uin, question: 'test question?', progress_id: Progress.pod_cleared.id, policy_minister_id: minister_1.id)
      pq_before = pq.dup
      pq.update(sent_to_answering_minister: DateTime.now, sent_to_policy_minister: DateTime.now)

      @pq_progress_changer_service.update_progress(pq_before, pq)

      pq = PQ.find_by(uin: uin)
      pq.progress.name.should eq(Progress.MINISTER_WAITING)
    end

    it 'should NOT move the question from POD_CLEARED to MINISTER_WAITING if sent_to_answering_minister completed and sent_to_policy_minister is NOT completed when policy minister is set' do
      uin = 'TEST1'
      pq = create(:PQ, uin: uin, question: 'test question?', progress_id: Progress.pod_cleared.id, policy_minister_id: minister_1.id)
      pq_before = pq.dup
      pq.update(sent_to_answering_minister: DateTime.now)

      @pq_progress_changer_service.update_progress(pq_before, pq)

      pq = PQ.find_by(uin: uin)
      pq.progress.name.should eq(Progress.POD_CLEARED)
    end

    it 'should NOT move the question to MINISTER_WAITING if the progress is not POD_CLEARED' do
      uin = 'TEST1'
      pq = create(:PQ, uin: uin, question: 'test question?', progress_id: Progress.pod_waiting.id)
      pq_before = pq.dup
      pq.update(sent_to_answering_minister: DateTime.now, sent_to_policy_minister: DateTime.now)

      @pq_progress_changer_service.update_progress(pq_before, pq)

      pq = PQ.find_by(uin: uin)
      pq.progress.name.should eq(Progress.POD_WAITING)
    end
  end


  describe 'Minister Query' do
    it 'should move the question from MINISTER_WAITING to MINISTER_QUERY if answering_minister_query true and there is no policy minister' do
      uin = 'TEST1'
      pq = create(:PQ, uin: uin, question: 'test question?', progress_id: Progress.minister_waiting.id)
      pq_before = pq.dup
      pq.update(answering_minister_query: true)

      @pq_progress_changer_service.update_progress(pq_before, pq)

      pq = PQ.find_by(uin: uin)
      pq.progress.name.should eq(Progress.MINISTER_QUERY)
    end

    it 'should move the question from MINISTER_WAITING to MINISTER_QUERY if policy_minister_query true when policy minister is set' do
      uin = 'TEST1'
      pq = create(:PQ, uin: uin, question: 'test question?', progress_id: Progress.minister_waiting.id, policy_minister_id: minister_1.id)
      pq_before = pq.dup
      pq.update(policy_minister_query: true)

      @pq_progress_changer_service.update_progress(pq_before, pq)

      pq = PQ.find_by(uin: uin)
      pq.progress.name.should eq(Progress.MINISTER_QUERY)
    end

    it 'should move the question from MINISTER_WAITING to MINISTER_QUERY if answering_minister_query true when policy minister is set' do
      uin = 'TEST1'
      pq = create(:PQ, uin: uin, question: 'test question?', progress_id: Progress.minister_waiting.id, policy_minister_id: minister_1.id)
      pq_before = pq.dup
      pq.update(answering_minister_query: true)

      @pq_progress_changer_service.update_progress(pq_before, pq)

      pq = PQ.find_by(uin: uin)
      pq.progress.name.should eq(Progress.MINISTER_QUERY)
    end


    it 'should NOT move the question to MINISTER_QUERY if the progress is not MINISTER_WAITING' do
      uin = 'TEST1'
      pq = create(:PQ, uin: uin, question: 'test question?', progress_id: Progress.pod_waiting.id)
      pq_before = pq.dup
      pq.update(answering_minister_query: true)

      @pq_progress_changer_service.update_progress(pq_before, pq)

      pq = PQ.find_by(uin: uin)
      pq.progress.name.should eq(Progress.POD_WAITING)
    end
  end



#  Minister Cleared - If - ‘cleared_by_policy_minister || cleared_by_answering_minister’ is completed - & remove from Minister Query (Both ministers need to be cleared if there are two)
  describe 'Minister Cleared' do
    it 'should move the question from MINISTER_QUERY to MINISTER_CLEARED if cleared_by_answering_minister completed and there is no policy minister' do
      uin = 'TEST1'
      pq = create(:PQ, uin: uin, question: 'test question?', progress_id: Progress.minister_query.id)
      pq_before = pq.dup
      pq.update(cleared_by_answering_minister: DateTime.now)

      @pq_progress_changer_service.update_progress(pq_before, pq)

      pq = PQ.find_by(uin: uin)
      pq.progress.name.should eq(Progress.MINISTER_CLEARED)
    end

    it 'should move the question from MINISTER_WAITING to MINISTER_CLEARED if cleared_by_answering_minister completed and there is no policy minister' do
      uin = 'TEST1'
      pq = create(:PQ, uin: uin, question: 'test question?', progress_id: Progress.minister_waiting.id)
      pq_before = pq.dup
      pq.update(cleared_by_answering_minister: DateTime.now)

      @pq_progress_changer_service.update_progress(pq_before, pq)

      pq = PQ.find_by(uin: uin)
      pq.progress.name.should eq(Progress.MINISTER_CLEARED)
    end


    it 'should move the question from MINISTER_QUERY to MINISTER_CLEARED if cleared_by_answering_minister and cleared_by_policy_minister is completed when policy minister is set' do
      uin = 'TEST1'
      pq = create(:PQ, uin: uin, question: 'test question?', progress_id: Progress.minister_query.id, policy_minister_id: minister_1.id)
      pq_before = pq.dup
      pq.update(cleared_by_answering_minister: DateTime.now, cleared_by_policy_minister: DateTime.now)

      @pq_progress_changer_service.update_progress(pq_before, pq)

      pq = PQ.find_by(uin: uin)
      pq.progress.name.should eq(Progress.MINISTER_CLEARED)
    end

    it 'should move the question from MINISTER_WAITING to MINISTER_CLEARED if cleared_by_answering_minister and cleared_by_policy_minister is completed when policy minister is set' do
      uin = 'TEST1'
      pq = create(:PQ, uin: uin, question: 'test question?', progress_id: Progress.minister_waiting.id, policy_minister_id: minister_1.id)
      pq_before = pq.dup
      pq.update(cleared_by_answering_minister: DateTime.now, cleared_by_policy_minister: DateTime.now)

      @pq_progress_changer_service.update_progress(pq_before, pq)

      pq = PQ.find_by(uin: uin)
      pq.progress.name.should eq(Progress.MINISTER_CLEARED)
    end

    it 'should NOT move the question from MINISTER_QUERY to MINISTER_CLEARED if cleared_by_answering_minister completed and cleared_by_policy_minister is NOT completed when policy minister is set' do
      uin = 'TEST1'
      pq = create(:PQ, uin: uin, question: 'test question?', progress_id: Progress.minister_query.id, policy_minister_id: minister_1.id)
      pq_before = pq.dup
      pq.update(cleared_by_answering_minister: DateTime.now)

      @pq_progress_changer_service.update_progress(pq_before, pq)

      pq = PQ.find_by(uin: uin)
      pq.progress.name.should eq(Progress.MINISTER_QUERY)
    end

    it 'should NOT move the question to MINISTER_CLEARED if the progress is not MINISTER_QUERY or MINISTER_WAITING' do
      uin = 'TEST1'
      pq = create(:PQ, uin: uin, question: 'test question?', progress_id: Progress.pod_waiting.id, policy_minister_id: minister_1.id)
      pq_before = pq.dup
      pq.update(cleared_by_answering_minister: DateTime.now, cleared_by_policy_minister: DateTime.now)

      @pq_progress_changer_service.update_progress(pq_before, pq)

      pq = PQ.find_by(uin: uin)
      pq.progress.name.should eq(Progress.POD_WAITING)
    end
  end






end