require 'spec_helper'

describe 'PQProgressChangerService' do

  let(:deputy_director) { create(:deputy_director, name: 'dd name', email: 'dd@dd.gov', id: 1+rand(10))}
  let(:action_officer) { create(:action_officer, name: 'ao name 1', email: 'ao@ao.gov', deputy_director_id: deputy_director.id) }
  let(:minister_1) { create(:minister, name: 'name1') }
  let(:minister) {build(:minister)}

  before(:each) do
    @pq_progress_changer_service = PQProgressChangerService.new
    @assignment_service = AssignmentService.new
    @comm_service = CommissioningService.new
    ActionMailer::Base.deliveries = []
  end

  describe 'POD Waiting' do
    it 'should move the question from DRAFT_PENDING to POD_WAITING if draft_answer_received is completed' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',  progress_id: Progress.draft_pending.id )

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)


      pq.update(draft_answer_received: DateTime.now)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.WITH_POD)
    end

    it 'should NOT move the question to POD_WAITING if the progress is not DRAFT_PENDING' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', progress_id: Progress.accepted.id)
    
      pq.update(draft_answer_received: DateTime.now)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.ACCEPTED)
    end
  end


  describe 'POD Query' do
    it 'should move the question from POD_WAITING to POD_QUERY if pod_query_flag is true' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',  progress_id: Progress.draft_pending.id )

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)

      pq.update(draft_answer_received: DateTime.now,
                pod_query_flag: true)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.POD_QUERY)
    end

    it 'should NOT move the question to POD_QUERY if the progress is not WITH_POD' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', progress_id: Progress.draft_pending.id)
      
      pq.update(pod_query_flag: true)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.DRAFT_PENDING)
    end
  end


  describe 'POD Cleared' do
    it 'should move the question from POD_WAITING to POD_CLEARED if pod_clearance completed' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',
                  progress_id: Progress.with_pod.id )

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)

      pq.update(draft_answer_received: DateTime.now,
                pod_query_flag: true,
                pod_clearance: DateTime.now)


      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.POD_CLEARED)
    end

    it 'should move the question from POD_QUERY to POD_CLEARED if pod_clearance completed' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',
                  progress_id: Progress.pod_query.id )

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)

      pq.update(draft_answer_received: DateTime.now,
                pod_query_flag: true,
                pod_clearance: DateTime.now)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.POD_CLEARED)
    end


    it 'should NOT move the question to POD_CLEARED if the progress is not POD_QUERY or POD_WAITING' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', progress_id: Progress.draft_pending.id)
      
      pq.update(pod_clearance: DateTime.now)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.DRAFT_PENDING)
    end
  end


  describe 'WITH MINISTER' do
    it 'should move the question from POD_CLEARED to MINISTER_WAITING if sent_to_answering_minister completed and there is no policy minister' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',  progress_id: Progress.draft_pending.id )

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)

      pq.update(draft_answer_received: DateTime.now,
                pod_query_flag: true,
                pod_clearance: DateTime.now,
                sent_to_answering_minister: DateTime.now)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.WITH_MINISTER)
    end

    it 'should move the question from POD_CLEARED to MINISTER_WAITING if sent_to_answering_minister and sent_to_policy_minister is completed when policy minister is set' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',  progress_id: Progress.draft_pending.id,
                  policy_minister_id: minister_1.id)

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)

      #pq = create(:Pq, uin: uin, question: 'test question?', progress_id: Progress.pod_cleared.id, policy_minister_id: minister_1.id)

      pq.update(draft_answer_received: DateTime.now,
                pod_query_flag: true,
                pod_clearance: DateTime.now,
                sent_to_answering_minister: DateTime.now, sent_to_policy_minister: DateTime.now)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.WITH_MINISTER)
    end

    it 'should NOT move the question from POD_CLEARED to MINISTER_WAITING if sent_to_answering_minister completed and sent_to_policy_minister is NOT completed when policy minister is set' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',  progress_id: Progress.draft_pending.id,
                  policy_minister_id: minister_1.id)

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)

      pq.update(draft_answer_received: DateTime.now,
                pod_query_flag: true,
                pod_clearance: DateTime.now,
                sent_to_answering_minister: DateTime.now)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.POD_CLEARED)
    end

    it 'should NOT move the question to MINISTER_WAITING if the progress is not POD_CLEARED' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',  progress_id: Progress.draft_pending.id)

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)

      pq.update(draft_answer_received: DateTime.now,
                sent_to_answering_minister: DateTime.now, sent_to_policy_minister: DateTime.now)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.WITH_POD)
    end
  end


  describe 'Minister Query' do
    it 'should move the question from MINISTER_WAITING to MINISTER_QUERY if answering_minister_query true and there is no policy minister' do
      uin = 'TEST1'

      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',
                  progress_id: Progress.with_minister.id)

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)


      pq.update(draft_answer_received: DateTime.now,
                pod_query_flag: true,
                pod_clearance: DateTime.now,
                sent_to_answering_minister: DateTime.now,
                answering_minister_query: true)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.MINISTERIAL_QUERY)
    end

    it 'should move the question from MINISTER_WAITING to MINISTER_QUERY if policy_minister_query true when policy minister is set' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',
                  progress_id: Progress.with_minister.id, policy_minister_id: minister_1.id)

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)

      pq.update(draft_answer_received: DateTime.now,
                pod_query_flag: true,
                pod_clearance: DateTime.now,
                sent_to_answering_minister: DateTime.now,
                sent_to_policy_minister: DateTime.now,
                answering_minister_query: true,
                policy_minister_query: true)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.MINISTERIAL_QUERY)
    end

    it 'should move the question from MINISTER_WAITING to MINISTER_QUERY if answering_minister_query true when policy minister is set' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',
                  progress_id: Progress.with_minister.id, policy_minister_id: minister_1.id)

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)
      pq.update(draft_answer_received: DateTime.now,
                pod_query_flag: true,
                pod_clearance: DateTime.now,
                sent_to_answering_minister: DateTime.now,
                sent_to_policy_minister: DateTime.now,
                answering_minister_query: true)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.MINISTERIAL_QUERY)
    end


    it 'should NOT move the question to MINISTER_QUERY if the progress is not MINISTER_WAITING' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',
                  progress_id: Progress.with_minister.id, policy_minister_id: minister_1.id)

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)

      pq.update(draft_answer_received: DateTime.now,
                answering_minister_query: true)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.WITH_POD)
    end
  end

  describe 'Minister Cleared' do
    it 'should move the question from MINISTER_QUERY to MINISTER_CLEARED if cleared_by_answering_minister completed and there is no policy minister' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',
                  progress_id: Progress.with_minister.id)

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)

      pq.update(draft_answer_received: DateTime.now,
                pod_query_flag: true,
                pod_clearance: DateTime.now,
                sent_to_answering_minister: DateTime.now,
                answering_minister_query: true,
                cleared_by_answering_minister: DateTime.now)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.MINISTER_CLEARED)
    end

    it 'should move the question from MINISTER_WAITING to MINISTER_CLEARED if cleared_by_answering_minister completed and there is no policy minister' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',
                  progress_id: Progress.with_minister.id)

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)

      pq.update(draft_answer_received: DateTime.now,
                pod_query_flag: true,
                pod_clearance: DateTime.now,
                sent_to_answering_minister: DateTime.now,
                cleared_by_answering_minister: DateTime.now)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.MINISTER_CLEARED)
    end


    it 'should move the question from MINISTER_QUERY to MINISTER_CLEARED if cleared_by_answering_minister and cleared_by_policy_minister is completed when policy minister is set' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',
                  progress_id: Progress.ministerial_query.id, policy_minister_id: minister_1.id)

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)

      pq.update(draft_answer_received: DateTime.now,
                pod_query_flag: true,
                pod_clearance: DateTime.now,
                sent_to_answering_minister: DateTime.now,
                sent_to_policy_minister: DateTime.now,
                answering_minister_query: true,
                cleared_by_answering_minister: DateTime.now,
               cleared_by_policy_minister: DateTime.now)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.MINISTER_CLEARED)
    end

    it 'should move the question from MINISTER_WAITING to MINISTER_CLEARED if cleared_by_answering_minister and cleared_by_policy_minister is completed when policy minister is set' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',
                  progress_id: Progress.with_minister.id, policy_minister_id: minister_1.id)

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)
      pq.update(draft_answer_received: DateTime.now,
                pod_query_flag: true,
                pod_clearance: DateTime.now,
                sent_to_answering_minister: DateTime.now,
                sent_to_policy_minister: DateTime.now,
                answering_minister_query: true,
                cleared_by_answering_minister: DateTime.now,
                cleared_by_policy_minister: DateTime.now)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.MINISTER_CLEARED)
    end

    it 'should NOT move the question from MINISTER_QUERY to MINISTER_CLEARED if cleared_by_answering_minister completed and cleared_by_policy_minister is NOT completed when policy minister is set' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',
                  progress_id: Progress.with_minister.id, policy_minister_id: minister_1.id)

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)
      pq.update(draft_answer_received: DateTime.now,
                pod_query_flag: true,
                pod_clearance: DateTime.now,
                sent_to_answering_minister: DateTime.now,
                sent_to_policy_minister: DateTime.now,
                answering_minister_query: true,
                cleared_by_answering_minister: DateTime.now)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.MINISTERIAL_QUERY)
    end

    it 'should NOT move the question to MINISTER_CLEARED if the progress is not MINISTER_QUERY or MINISTER_WAITING' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',
                  progress_id: Progress.with_minister.id, policy_minister_id: minister_1.id)

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)
      pq.update(draft_answer_received: DateTime.now,
                pod_query_flag: true,
                pod_clearance: DateTime.now,
                cleared_by_answering_minister: DateTime.now,
                cleared_by_policy_minister: DateTime.now)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.POD_CLEARED)
    end
  end


  #  *Remove from dashboard - if - 'answer_submitted || pq_withdrawn’ is completed
  describe 'Answered (remove from dashboard)' do
    it 'should move the question from MINISTER_CLEARED to ANSWERED if answer_submitted completed' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',
                  progress_id: Progress.minister_cleared.id, policy_minister_id: minister_1.id)

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)

      pq.update(draft_answer_received: DateTime.now,
                pod_query_flag: true,
                pod_clearance: DateTime.now,
                sent_to_answering_minister: DateTime.now,
                sent_to_policy_minister: DateTime.now,
                answering_minister_query: true,
                cleared_by_answering_minister: DateTime.now,
                cleared_by_policy_minister: DateTime.now,
                answer_submitted: DateTime.now)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.ANSWERED)
    end

    it 'should move the question from MINISTER_CLEARED to ANSWERED if pq_withdrawn set' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',
                  progress_id: Progress.minister_cleared.id, policy_minister_id: minister_1.id)

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)

      pq.update(draft_answer_received: DateTime.now,
                pod_query_flag: true,
                pod_clearance: DateTime.now,
                sent_to_answering_minister: DateTime.now,
                sent_to_policy_minister: DateTime.now,
                answering_minister_query: true,
                cleared_by_answering_minister: DateTime.now,
                cleared_by_policy_minister: DateTime.now,
                pq_withdrawn: DateTime.now)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.ANSWERED)
    end

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


    it 'should NOT move the question to ANSWERED if the progress is not MINISTER_CLEARED' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',
                  progress_id: Progress.minister_cleared.id, policy_minister_id: minister_1.id)

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)

      pq.update(draft_answer_received: DateTime.now,
                pod_query_flag: true,
                pod_clearance: DateTime.now,
                sent_to_answering_minister: DateTime.now,
                answering_minister_query: true,
                answer_submitted: DateTime.now)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.POD_CLEARED)
    end
  end


  describe 'From DRAFT_PENDING to ANSWERED' do
    it 'should move the question from DRAFT_PENDING to ANSWERED if all the data necessary is set' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons',
                  progress_id: Progress.draft_pending.id)

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

      result = @comm_service.send(assignment)
      @assignment_service.accept(assignment)

      pq.update(draft_answer_received: DateTime.now,
                pod_query_flag: true,
                pod_clearance: DateTime.now,
                sent_to_answering_minister: DateTime.now,
                answering_minister_query: true,
                cleared_by_answering_minister: DateTime.now,
                answer_submitted: DateTime.now)


      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.ANSWERED)
    end
  end


  describe 'TRANSFERRED_OUT' do
    it 'should move from any other status when relevant data is set' do
      uin = 'TEST1'
      pq = create(:Pq, uin: uin, question: 'test question?', progress_id: Progress.draft_pending.id)
      pq.update(transfer_out_ogd_id: DateTime.now,
                transfer_out_date: DateTime.now)

      @pq_progress_changer_service.update_progress(pq)

      pq = Pq.find_by(uin: uin)
      pq.progress.name.should eq(Progress.TRANSFERRED_OUT)
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



      puts "?Draft Pending? " + pq.progress.name.to_s
      pq.progress.name.should eq(Progress.DRAFT_PENDING)

    end

  end
end