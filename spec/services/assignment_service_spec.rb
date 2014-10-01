require 'spec_helper'

describe 'AssignmentService' do
  let(:minister) {build(:minister)}
  let(:directorate) {create(:directorate, name: 'This Directorate', id: 1+rand(10))}
  let(:division) {create(:division,name: 'Division', directorate_id: directorate.id, id: 1+rand(10))}
  let(:deputy_director) { create(:deputy_director, name: 'dd name', division_id: division.id, id: 1+rand(10))}
  let(:action_officer) { create(:action_officer, name: 'ao name 1', email: 'ao@ao.gov', deputy_director_id: deputy_director.id) }
  let(:action_officer2) { create(:action_officer, name: 'ao name 2', email: 'ao@ao.gov') }

  let(:pq) { create(:Pq, uin: 'HL789', question: 'test question?',minister:minister, house_name:'commons') }
  progress_seed

  before(:each) do
    @assignment_service = AssignmentService.new
    @comm_service = CommissioningService.new
    ActionMailer::Base.deliveries = []
  end


  describe '#accept' do
    it 'should set the right flags in the assignment' do

      # setup a valid assignment
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      assignment.should_not be nil

      @assignment_service.accept(assignment)

      assignment = ActionOfficersPq.find(assignment_id)

      assignment.accept.should eq(true)
      assignment.reject.should eq(false)

    end

    it 'should create an audit event storing the action officer name' do
      # setup a valid assignment
      PaperTrail.enabled=true

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      assignment.should_not be nil


      @assignment_service.accept(assignment)

      # assignment = ActionOfficersPq.find(assignment_id)

      expect(assignment.versions.size).to eql(2) # Create and update
      update = assignment.versions.last
      expect(update.whodunnit).to eql('AO:ao name 1')
    end

    it 'should sent an email with the accept data' do

      # setup a valid assignment
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      assignment.should_not be nil

      #clear the mail queue
      ActionMailer::Base.deliveries = []

      @assignment_service.accept(assignment)

      assignment = ActionOfficersPq.find(assignment_id)

      mail = ActionMailer::Base.deliveries.first

      mail.html_part.body.should include pq.question
      mail.subject.should include pq.uin

    end


    it 'should set the progress to Allocated Accepted' do

      # setup a valid assignment
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      assignment.should_not be nil

      @assignment_service.accept(assignment)

      assignment = ActionOfficersPq.find(assignment_id)

      pq = Pq.find(assignment.pq_id)
      pq.progress.name.should  eq(Progress.ACCEPTED)

    end

    it 'should set the original division_id on PQ' do
      # setup a valid assignment
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      assignment.should_not be nil

      @assignment_service.accept(assignment)

      assignment = ActionOfficersPq.find(assignment_id)

      pq = Pq.find(assignment.pq_id)
      pq.at_acceptance_division_id.should eq(division.id)
    end
    it 'should set the original directorate on PQ' do
      # setup a valid assignment
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      assignment.should_not be nil

      @assignment_service.accept(assignment)

      assignment = ActionOfficersPq.find(assignment_id)

      pq = Pq.find(assignment.pq_id)
      pq.at_acceptance_directorate_id.should eq(directorate.id)
    end
    it 'should set the directorate on acceptance and not change if AO moves' do
      # setup a valid assignment
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      assignment.should_not be nil

      @assignment_service.accept(assignment)

      assignment = ActionOfficersPq.find(assignment_id)

      pq = Pq.find(assignment.pq_id)
      pq.at_acceptance_directorate_id.should eq(directorate.id)

      new_dir = create(:directorate, name: 'New Directorate', id:  Directorate.maximum(:id).next)
      new_div = create(:division,name: 'New Division', directorate_id: new_dir.id, id:  Division.maximum(:id).next)
      new_dd = create(:deputy_director, name: 'dd name', division_id: new_div.id, id:   10+DeputyDirector.maximum(:id).next)

      action_officer.update(:deputy_director_id => new_dd.id)

      pq.at_acceptance_directorate_id.should eql(directorate.id)
      assignment.action_officer.deputy_director_id.should eql(new_dd.id)
      pq.at_acceptance_directorate_id.should_not eql(new_dd.id)
    end

    it 'should not crash id division is nil' do
      # setup a valid assignment
      assignment = ActionOfficersPq.new(action_officer_id: action_officer2.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      assignment.should_not be nil

      @assignment_service.accept(assignment)

      assignment = ActionOfficersPq.find(assignment_id)

      pq = Pq.find(assignment.pq_id)
      pq.at_acceptance_directorate_id.should eq(nil)
    end

  end


  describe '#reject' do
    it 'should set the right flags in the assignment' do

      # setup a valid assignment
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      assignment.should_not be nil

      response = double('response')
      allow(response).to receive(:reason) { 'Some reason' }
      allow(response).to receive(:reason_option) { 'reason option' }
      @assignment_service.reject(assignment, response)

      assignment = ActionOfficersPq.find(assignment_id)

      assignment.accept.should eq(false)
      assignment.reject.should eq(true)

      assignment.reason.should eq('Some reason')
      assignment.reason_option.should eq('reason option')

    end

    it 'should create an audit event storing the action officer name' do
      # setup a valid assignment
      PaperTrail.enabled=true

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      assignment.should_not be nil

      response = double('response')
      allow(response).to receive(:reason) { 'Some reason' }
      allow(response).to receive(:reason_option) { 'reason option' }
      @assignment_service.reject(assignment, response)

      # assignment = ActionOfficersPq.find(assignment_id)

      expect(assignment.versions.size).to eql(2) # Create and update
      update = assignment.versions.last
      expect(update.whodunnit).to eql('AO:ao name 1')
    end

    it 'should set the progress to rejected' do
      #pq.action_officers_pq.clear()
      # setup a valid assignment
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      assignment.should_not be nil

      response = double('response')
      allow(response).to receive(:reason) { 'Some reason' }
      allow(response).to receive(:reason_option) { 'reason option' }
      @assignment_service.reject(assignment, response)

      assignment = ActionOfficersPq.find(assignment_id)

      pq = Pq.find(assignment.pq_id)
      pq.progress.name.should  eq(Progress.REJECTED)
    end


    it 'should not set the progress to rejected if it is accepted' do

      # accept one  assignment
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      assignment.should_not be nil
      # accept
      @assignment_service.accept(assignment)

      # the question progress should be ALLOCATED_ACCEPTED if at least one ao is accepted
      pq = Pq.find(assignment.pq_id)
      pq.progress.name.should  eq(Progress.ACCEPTED)


      # setup another assignment and reject assignment
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      assignment.should_not be nil
      response = double('response')
      allow(response).to receive(:reason) { 'Some reason' }
      allow(response).to receive(:reason_option) { 'reason option' }
      #reject
      @assignment_service.reject(assignment, response)
      assignment = ActionOfficersPq.find(assignment_id)

      # the question progress should be ALLOCATED_ACCEPTED even after the reject
      pq = Pq.find(assignment.pq_id)
      pq.progress.name.should  eq(Progress.ACCEPTED)

    end

    it 'should not set the progress to rejected when you change your mind and put it again to rejected' do

      # accept one  assignment
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      assignment.should_not be nil
      # accept
      @assignment_service.accept(assignment)

      # reject the previous one
      response = double('response')
      allow(response).to receive(:reason) { 'Some reason' }
      allow(response).to receive(:reason_option) { 'reason option' }
      @assignment_service.reject(assignment, response)

      # the question progress should be REJECTED
      pq = Pq.find(assignment.pq_id)
      pq.progress.name.should  eq(Progress.REJECTED)

    end

    it 'should only set the progress to rejected when all action officers reject' do
      #set up the pq with three assignments
      assignment1 = ActionOfficersPq.create(action_officer_id: action_officer.id, pq_id: pq.id)
      assignment2 = ActionOfficersPq.create(action_officer_id: action_officer.id, pq_id: pq.id)
      assignment3 = ActionOfficersPq.create(action_officer_id: action_officer.id, pq_id: pq.id)
      #belt and braces!
      pq.action_officers_pq.size.should eq(3)
      #set assignment 1 to be rejected
      response = double('response')
      allow(response).to receive(:reason) { 'Some reason' }
      allow(response).to receive(:reason_option) { 'reason option' }
      #reject assignment1
      @assignment_service.reject(assignment1, response)
      pq = Pq.find(assignment1.pq_id)
      pq.progress.name.should  eq(Progress.NO_RESPONSE)
      #reject assignment2
      @assignment_service.reject(assignment2, response)
      pq = Pq.find(assignment2.pq_id)
      pq.progress.name.should  eq(Progress.NO_RESPONSE)
      #reject assignment3
      @assignment_service.reject(assignment3, response)
      pq = Pq.find(assignment3.pq_id)
      pq.progress.name.should  eq(Progress.REJECTED)
    end
  end
end
