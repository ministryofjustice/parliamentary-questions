require 'spec_helper'

describe PqFollowup do
  # let(:pq) {
  #   DBHelpers.pqs.first
  # }

  let(:directorate) { create(:directorate, name: 'This Directorate', id: rand(1..10)) }
  let(:division) { create(:division, name: 'Division', directorate_id: directorate.id, id: rand(1..10)) }
  let(:deputy_director) { create(:deputy_director, name: 'dd name', division_id: division.id, id: rand(1..10)) }
  let(:minister) { build(:minister) }
  let(:action_officer) { create(:action_officer, name: 'ao name 1', email: 'ao@ao.gov', deputy_director_id: deputy_director.id) }
  let(:pq) { create(:pq, uin: 'HL789', question: 'test question?', minister: minister, house_name: 'commons', i_will_write: true) }
  let(:commissioning_service) { CommissioningService.new }
  before(:each) do
    ActionMailer::Base.deliveries = []
  end
  let(:assignment) { ActionOfficersPq.new(action_officer: action_officer, pq: pq) }

  it 'should check follow up has been created' do
    service = AssignmentService.new
    service.accept(assignment)
    pq2 = pq.find_or_create_follow_up

    expect(pq2.uin).to eql('HL789-IWW')
  end

  it 'should check if action officer has been created' do
    service = AssignmentService.new
    service.accept(assignment)
    pq2 = pq.find_or_create_follow_up
    aopq = pq2.action_officers_pqs.where(pq_id: pq2.id).take
    expect(aopq.action_officer.name).to eql('ao name 1')
  end
end
