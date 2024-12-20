require "rails_helper"

describe AssignmentService do
  subject(:assignment_service) { described_class.new }

  let(:action_officer) { create(:action_officer, name: "ao name 1", email: "ao@ao.gov", deputy_director_id: deputy_director.id) }
  let(:assignment) { ActionOfficersPq.new(action_officer:, pq:) }
  let(:commissioning_service) { CommissioningService.new }
  let(:deputy_director) { create(:deputy_director, name: "dd name", division_id: division.id) }
  let(:directorate) { create(:directorate, name: "This Directorate") }
  let(:division) { create(:division, name: "Division", directorate_id: directorate.id) }

  let(:form) do
    CommissionForm.new(
      pq_id: pq.id,
      minister_id: minister.id,
      action_officer_id: [action_officer.id],
      date_for_answer: Date.tomorrow,
      internal_deadline: Time.zone.today,
    )
  end

  let(:minister) { build(:minister) }
  let(:pq) { create(:pq, uin: "HL789", question: "test question?", minister:, house_name: "commons") }

  describe "#accept" do
    it "accepts the assignment" do
      expect(assignment).to receive(:accept)
      assignment_service.accept(assignment)
    end

    it "sets pq state to DRAFT_PENDING" do
      assignment_service.accept(assignment)
      expect(pq.state).to eq(PqState::DRAFT_PENDING)
    end

    it "calls the mailer" do
      allow(NotifyPqMailer).to receive_message_chain(:acceptance_email, :deliver_later) # rubocop:disable RSpec/MessageChain
      assignment_service.accept(assignment)
      expect(NotifyPqMailer).to have_received(:acceptance_email).with(pq:, action_officer:, email: action_officer.email)
    end

    it "sets the original division_id on PQ" do
      pq = commissioning_service.commission(form)
      assignment_id = pq.action_officers_pqs.first.id
      assignment = ActionOfficersPq.find(assignment_id)
      expect(assignment).not_to be_nil
      assignment_service.accept(assignment)
      assignment = ActionOfficersPq.find(assignment_id)
      pq = Pq.find(assignment.pq_id)
      expect(pq.original_division_id).to eq(division.id)
    end

    it "sets the original directorate on PQ" do
      pq = commissioning_service.commission(form)
      assignment_id = pq.action_officers_pqs.first.id
      assignment = ActionOfficersPq.find(assignment_id)
      expect(assignment).not_to be_nil
      assignment_service.accept(assignment)
      assignment = ActionOfficersPq.find(assignment_id)
      pq = Pq.find(assignment.pq_id)
      expect(pq.directorate_id).to eq(directorate.id)
    end

    it "sets the directorate on acceptance and not change if AO moves" do
      pq = commissioning_service.commission(form)
      assignment_id = pq.action_officers_pqs.first.id
      assignment = ActionOfficersPq.find(assignment_id)
      expect(assignment).not_to be_nil
      assignment_service.accept(assignment)
      assignment = ActionOfficersPq.find(assignment_id)
      pq = Pq.find(assignment.pq_id)
      expect(pq.directorate_id).to eq(directorate.id)
      new_dir = create(:directorate, name: "New Directorate")
      new_div = create(:division, name: "New Division", directorate_id: new_dir.id)
      new_dd = create(:deputy_director, name: "dd name", division_id: new_div.id)
      action_officer.update!(deputy_director_id: new_dd.id)
      expect(pq.directorate_id).to eql(directorate.id)
      expect(assignment.action_officer.deputy_director_id).to eql(new_dd.id)
      expect(pq.directorate_id).not_to eql(new_dd.id)
    end
  end

  describe "#reject" do
    let(:reason) { double(reason_option: "reason option", reason: "Some reason") } # rubocop:disable RSpec/VerifiedDoubles

    it "rejects the assignment" do
      expect(assignment).to receive(:reject).with "reason option", "Some reason"
      assignment_service.reject(assignment, reason)
    end

    it "updates progress" do
      assignment_service.reject(assignment, reason)
      expect(pq.state).to eq(PqState::REJECTED)
    end
  end
end
