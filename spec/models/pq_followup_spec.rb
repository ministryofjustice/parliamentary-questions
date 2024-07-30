require "rails_helper"

describe PqFollowup do
  # let(:pq) {
  #   DbHelpers.pqs.first
  # }

  let(:directorate) { create(:directorate, name: "This Directorate") }
  let(:assignment) { ActionOfficersPq.new(action_officer:, pq:) }
  let(:division) { create(:division, name: "Division", directorate_id: directorate.id) }
  let(:deputy_director) { create(:deputy_director, name: "dd name", division_id: division.id) }
  let(:minister) { build(:minister) }
  let(:action_officer) { create(:action_officer, name: "ao name 1", email: "ao@ao.gov", deputy_director_id: deputy_director.id) }
  let(:pq) { create(:pq, uin: "HL789", question: "test question?", minister:, house_name: "commons", i_will_write: true) }
  let(:commissioning_service) { CommissioningService.new }

  before do
    ActionMailer::Base.deliveries = []
  end

  it "checks follow up has been created" do
    service = AssignmentService.new
    service.accept(assignment)
    pq2 = pq.find_or_create_follow_up

    expect(pq2.uin).to eql("HL789-IWW")
  end

  it "checks if action officer has been created" do
    service = AssignmentService.new
    service.accept(assignment)
    pq2 = pq.find_or_create_follow_up
    aopq = pq2.action_officers_pqs.find_by(pq_id: pq2.id)
    expect(aopq.action_officer.name).to eql("ao name 1")
  end
end
