require 'spec_helper'
require 'paper_trail/frameworks/rspec'

describe AssignmentService do
  let(:minister) { build(:minister) }

  let(:form) { 
    CommissionForm.new({
      pq_id: pq.id,
      minister_id: minister.id,
      action_officer_id: [action_officer.id],
      date_for_answer: Date.tomorrow,
      internal_deadline: Date.today
    })
  }

  let(:directorate) {create(:directorate, name: 'This Directorate', id: 1+rand(10))}
  let(:division) {create(:division,name: 'Division', directorate_id: directorate.id, id: 1+rand(10))}
  let(:deputy_director) { create(:deputy_director, name: 'dd name', division_id: division.id, id: 1+rand(10))}
  let(:action_officer) { create(:action_officer, name: 'ao name 1', email: 'ao@ao.gov', deputy_director_id: deputy_director.id) }
  let(:commissioning_service) { CommissioningService.new }

  let(:pq) { create(:pq, uin: 'HL789', question: 'test question?',minister:minister, house_name:'commons') }

  before(:each) do
    ActionMailer::Base.deliveries = []
  end

  let(:assignment) { ActionOfficersPq.new(action_officer: action_officer, pq: pq) }

  describe '#accept' do
    it 'accepts the assignment' do
      expect(assignment).to receive(:accept)
      subject.accept(assignment)
    end

    it 'sets pq state to DRAFT_PENDING' do
      subject.accept(assignment)
      expect(pq.state).to eq(PQState::DRAFT_PENDING)
    end

    with_versioning do
      it 'should create an audit event storing the action officer name' do
      PaperTrail.enabled = true
      pq = commissioning_service.commission(form)

      assignment_id = pq.action_officers_pqs.first.id
      assignment = ActionOfficersPq.find(assignment_id)
      expect(assignment).to_not be nil

      subject.accept(assignment)

      expect(assignment.versions.size).to eql(2) # Create and update
      update = assignment.versions.last
      expect(update.whodunnit).to eql('AO:ao name 1')
      end
    end

    it 'should sent an email with the accept data' do
      pq            = commissioning_service.commission(form)
      assignment_id = pq.action_officers_pqs.first.id
      assignment    = ActionOfficersPq.find(assignment_id)
      
      expect(assignment).to_not be nil

      ActionMailer::Base.deliveries = []
      subject.accept(assignment)
      assignment = ActionOfficersPq.find(assignment_id)
      MailWorker.new.run!
      mail = ActionMailer::Base.deliveries.first
      
      expect(mail.html_part.body).to include pq.question
      expect(mail.subject).to include pq.uin
    end

    it 'should set the original division_id on PQ' do
      pq = commissioning_service.commission(form)
      assignment_id = pq.action_officers_pqs.first.id
      assignment = ActionOfficersPq.find(assignment_id)
      expect(assignment).to_not be nil

      subject.accept(assignment)

      assignment = ActionOfficersPq.find(assignment_id)

      pq = Pq.find(assignment.pq_id)
      expect(pq.original_division_id).to eq(division.id)
    end

    it 'should set the original directorate on PQ' do
      pq = commissioning_service.commission(form)
      assignment_id = pq.action_officers_pqs.first.id

      assignment = ActionOfficersPq.find(assignment_id)
      expect(assignment).to_not be nil

      subject.accept(assignment)

      assignment = ActionOfficersPq.find(assignment_id)

      pq = Pq.find(assignment.pq_id)
      expect(pq.directorate_id).to eq(directorate.id)
    end

    it 'should set the directorate on acceptance and not change if AO moves' do
      pq = commissioning_service.commission(form)
      assignment_id = pq.action_officers_pqs.first.id

      assignment = ActionOfficersPq.find(assignment_id)
      expect(assignment).to_not be nil

      subject.accept(assignment)

      assignment = ActionOfficersPq.find(assignment_id)

      pq = Pq.find(assignment.pq_id)
      expect(pq.directorate_id).to eq(directorate.id)

      new_dir = create(:directorate, name: 'New Directorate', id:  Directorate.maximum(:id).next)
      new_div = create(:division,name: 'New Division', directorate_id: new_dir.id, id:  Division.maximum(:id).next)
      new_dd = create(:deputy_director, name: 'dd name', division_id: new_div.id, id:   10+DeputyDirector.maximum(:id).next)

      action_officer.update(:deputy_director_id => new_dd.id)

      expect(pq.directorate_id).to eql(directorate.id)
      expect(assignment.action_officer.deputy_director_id).to eql(new_dd.id)
      expect(pq.directorate_id).to_not eql(new_dd.id)
    end
  end

  describe '#reject' do
    let(:reason) { double(reason_option: 'reason option', reason: 'Some reason') }

    it 'rejects the assignment' do
      expect(assignment).to receive(:reject).with 'reason option', 'Some reason'
      subject.reject(assignment, reason)
    end

    it 'updates progress' do
      subject.reject(assignment, reason)
      expect(pq.state).to eq(PQState::REJECTED)
    end

    it 'should create an audit event storing the action officer name' do
      PaperTrail.enabled=true
      pq = commissioning_service.commission(form)
      assignment_id = pq.action_officers_pqs.first.id

      assignment = ActionOfficersPq.find(assignment_id)
      expect(assignment).to_not be nil

      response = double('response')
      allow(response).to receive(:reason) { 'Some reason' }
      allow(response).to receive(:reason_option) { 'reason option' }
      subject.reject(assignment, response)

      expect(assignment.versions.size).to eql(2)
      update = assignment.versions.last
      expect(update.whodunnit).to eql('AO:ao name 1')
    end
  end
end
