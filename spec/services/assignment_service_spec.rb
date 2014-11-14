require 'spec_helper'

describe 'AssignmentService' do
  let(:minister) {build(:minister)}
  let(:directorate) {create(:directorate, name: 'This Directorate', id: 1+rand(10))}
  let(:division) {create(:division,name: 'Division', directorate_id: directorate.id, id: 1+rand(10))}
  let(:deputy_director) { create(:deputy_director, name: 'dd name', division_id: division.id, id: 1+rand(10))}
  let(:action_officer) { create(:action_officer, name: 'ao name 1', email: 'ao@ao.gov', deputy_director_id: deputy_director.id) }

  let(:pq) { create(:pq, uin: 'HL789', question: 'test question?',minister:minister, house_name:'commons') }

  before(:each) do
    @assignment_service = AssignmentService.new
    @comm_service = CommissioningService.new
    ActionMailer::Base.deliveries = []
  end

  describe '#accept' do
    it 'should set the right flags in the assignment' do
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      expect(assignment).to_not be nil

      @assignment_service.accept(assignment)

      assignment = ActionOfficersPq.find(assignment_id)

      expect(assignment.accept).to eq(true)
      expect(assignment.reject).to eq(false)
    end

    it 'should create an audit event storing the action officer name' do
      PaperTrail.enabled = true

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      expect(assignment).to_not be nil

      @assignment_service.accept(assignment)

      expect(assignment.versions.size).to eql(2) # Create and update
      update = assignment.versions.last
      expect(update.whodunnit).to eql('AO:ao name 1')
    end

    it 'should sent an email with the accept data' do
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      expect(assignment).to_not be nil

      ActionMailer::Base.deliveries = []
      @assignment_service.accept(assignment)
      assignment = ActionOfficersPq.find(assignment_id)
      mail = ActionMailer::Base.deliveries.first
      expect(mail.html_part.body).to include pq.question
      expect(mail.subject).to include pq.uin
    end


    it 'should set the progress to Allocated Accepted' do
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      expect(assignment).to_not be nil

      @assignment_service.accept(assignment)

      assignment = ActionOfficersPq.find(assignment_id)

      pq = Pq.find(assignment.pq_id)
      expect(pq.progress.name).to  eq(Progress.ACCEPTED)
    end

    it 'should set the original division_id on PQ' do
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      expect(assignment).to_not be nil

      @assignment_service.accept(assignment)

      assignment = ActionOfficersPq.find(assignment_id)

      pq = Pq.find(assignment.pq_id)
      expect(pq.at_acceptance_division_id).to eq(division.id)
    end

    it 'should set the original directorate on PQ' do
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      expect(assignment).to_not be nil

      @assignment_service.accept(assignment)

      assignment = ActionOfficersPq.find(assignment_id)

      pq = Pq.find(assignment.pq_id)
      expect(pq.at_acceptance_directorate_id).to eq(directorate.id)
    end

    it 'should set the directorate on acceptance and not change if AO moves' do
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      expect(assignment).to_not be nil

      @assignment_service.accept(assignment)

      assignment = ActionOfficersPq.find(assignment_id)

      pq = Pq.find(assignment.pq_id)
      expect(pq.at_acceptance_directorate_id).to eq(directorate.id)

      new_dir = create(:directorate, name: 'New Directorate', id:  Directorate.maximum(:id).next)
      new_div = create(:division,name: 'New Division', directorate_id: new_dir.id, id:  Division.maximum(:id).next)
      new_dd = create(:deputy_director, name: 'dd name', division_id: new_div.id, id:   10+DeputyDirector.maximum(:id).next)

      action_officer.update(:deputy_director_id => new_dd.id)

      expect(pq.at_acceptance_directorate_id).to eql(directorate.id)
      expect(assignment.action_officer.deputy_director_id).to eql(new_dd.id)
      expect(pq.at_acceptance_directorate_id).to_not eql(new_dd.id)
    end
  end

  describe '#reject' do
    it 'should set the right flags in the assignment' do
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      expect(assignment).to_not be nil

      response = double('response')
      allow(response).to receive(:reason) { 'Some reason' }
      allow(response).to receive(:reason_option) { 'reason option' }
      @assignment_service.reject(assignment, response)

      assignment = ActionOfficersPq.find(assignment_id)

      expect(assignment.accept).to eq(false)
      expect(assignment.reject).to eq(true)

      expect(assignment.reason).to eq('Some reason')
      expect(assignment.reason_option).to eq('reason option')
    end

    it 'should create an audit event storing the action officer name' do
      PaperTrail.enabled=true

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      expect(assignment).to_not be nil

      response = double('response')
      allow(response).to receive(:reason) { 'Some reason' }
      allow(response).to receive(:reason_option) { 'reason option' }
      @assignment_service.reject(assignment, response)

      expect(assignment.versions.size).to eql(2)
      update = assignment.versions.last
      expect(update.whodunnit).to eql('AO:ao name 1')
    end

    it 'should set the progress to rejected' do
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      expect(assignment).to_not be nil

      response = double('response')
      allow(response).to receive(:reason) { 'Some reason' }
      allow(response).to receive(:reason_option) { 'reason option' }
      @assignment_service.reject(assignment, response)

      assignment = ActionOfficersPq.find(assignment_id)

      pq = Pq.find(assignment.pq_id)
      expect(pq.progress.name).to  eq(Progress.REJECTED)
    end


    it 'should not set the progress to rejected if it is accepted' do
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      expect(assignment).to_not be nil
      @assignment_service.accept(assignment)

      pq = Pq.find(assignment.pq_id)
      expect(pq.progress.name).to  eq(Progress.ACCEPTED)

      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      expect(assignment).to_not be nil
      response = double('response')
      allow(response).to receive(:reason) { 'Some reason' }
      allow(response).to receive(:reason_option) { 'reason option' }

      @assignment_service.reject(assignment, response)
      assignment = ActionOfficersPq.find(assignment_id)

      pq = Pq.find(assignment.pq_id)
      expect(pq.progress.name).to  eq(Progress.ACCEPTED)
    end

    it 'should not set the progress to rejected when you change your mind and put it again to rejected' do
      assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)
      result = @comm_service.send(assignment)
      assignment_id = result[:assignment_id]
      assignment = ActionOfficersPq.find(assignment_id)
      expect(assignment).to_not be nil

      @assignment_service.accept(assignment)

      response = double('response')
      allow(response).to receive(:reason) { 'Some reason' }
      allow(response).to receive(:reason_option) { 'reason option' }
      @assignment_service.reject(assignment, response)

      pq = Pq.find(assignment.pq_id)
      expect(pq.progress.name).to  eq(Progress.REJECTED)
    end

    it 'should only set the progress to rejected when all action officers reject' do
      assignment1 = ActionOfficersPq.create(action_officer_id: action_officer.id, pq_id: pq.id)
      assignment2 = ActionOfficersPq.create(action_officer_id: action_officer.id, pq_id: pq.id)
      assignment3 = ActionOfficersPq.create(action_officer_id: action_officer.id, pq_id: pq.id)
      expect(pq.action_officers_pq.size).to eq(3)
      response = double('response')
      allow(response).to receive(:reason) { 'Some reason' }
      allow(response).to receive(:reason_option) { 'reason option' }

      @assignment_service.reject(assignment1, response)
      pq = Pq.find(assignment1.pq_id)
      expect(pq.progress.name).to  eq(Progress.NO_RESPONSE)

      @assignment_service.reject(assignment2, response)
      pq = Pq.find(assignment2.pq_id)
      expect(pq.progress.name).to  eq(Progress.NO_RESPONSE)

      @assignment_service.reject(assignment3, response)
      pq = Pq.find(assignment3.pq_id)
      expect(pq.progress.name).to  eq(Progress.REJECTED)
    end
  end
end
