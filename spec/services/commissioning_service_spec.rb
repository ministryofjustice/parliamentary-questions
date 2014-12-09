require 'spec_helper'

describe CommissioningService do
  let(:minister) {build(:minister)}
  let(:deputy_director) { create(:deputy_director, name: 'dd name', email: 'dd@dd.gov', id: 1+rand(10))}
  let(:action_officer) { create(:action_officer, name: 'ao name 1', email: 'ao@ao.gov', deputy_director_id: deputy_director.id) }
  let(:pq) { create(:question, uin: 'HL789', text: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons' ) }

  let(:deputy_director2) { create(:deputy_director, name: 'dd name', email: '', id: 1+rand(10))}
  let(:action_officer2) { create(:action_officer, name: 'ao name 1', email: 'ao@ao.gov', deputy_director_id: deputy_director2.id) }
  let(:assignment) { create(:action_officers_pq, action_officer: action_officer, pq: pq) }

  before(:each) do
    ActionMailer::Base.deliveries = []
  end

  it 'should return the assignment id and inserts the data' do
    result = subject.commission(assignment)

    expect(result).to_not be nil
    expect(result[:assignment_id]).to_not be nil

    expect(ActionOfficersPq.where(action_officer_id: action_officer.id, pq_id: pq.id).first).to_not be nil
  end

  it 'should have generated a valid token' do
    result = subject.commission(assignment)

    token = Token.where(entity: "assignment:#{result[:assignment_id]}", path: '/assignment/HL789').first

    expect(token).to_not be nil
    expect(token.id).to_not be nil
    expect(token.token_digest).to_not be nil

    token_expires = DateTime.now.midnight.change({:offset => 0}) + 3.days
    expect(token.expire).to eq(token_expires)
  end

  it 'should send an email with the right data' do
    result = subject.commission(assignment)
    sentToken = result[:token]

    mail = ActionMailer::Base.deliveries.first

    token_param = {token: sentToken}.to_query
    entity = {entity: "assignment:#{result[:assignment_id]}"}.to_query
    url = "/assignment/HL789"

    expect(mail.html_part.body).to include pq.text
    expect(mail.html_part.body).to include action_officer.name
    expect(mail.html_part.body).to include url
    expect(mail.html_part.body).to include token_param
    expect(mail.html_part.body).to include entity

    expect(mail.text_part.body).to include pq.text
    expect(mail.text_part.body).to include action_officer.name
    expect(mail.text_part.body).to include url
    expect(mail.text_part.body).to include token_param
    expect(mail.text_part.body).to include entity

    expect(mail.to).to include action_officer.email
  end


  it 'should raise an error if the action_officer.id is null' do
    assignment = ActionOfficersPq.new(pq_id: pq.id)
    expect {
      subject.commission(assignment)
    }.to raise_error 'Action Officer is not selected'
  end

  it 'should raise an error if the pq_id is null' do
    assignment = ActionOfficersPq.new(action_officer_id: action_officer.id)
    expect {
      subject.commission(assignment)
    }.to raise_error 'Question is not selected'
  end

  it 'should send an email to the deputy director the right data' do
    result = subject.notify_dd(assignment)
    mail = ActionMailer::Base.deliveries.first

    expect(mail.html_part.body).to include pq.uin
    expect(mail.html_part.body).to include pq.text
    expect(mail.html_part.body).to include pq.member_name
    expect(mail.html_part.body).to include pq.internal_deadline.to_s(:date)
    expect(mail.html_part.body).to include action_officer.name
    expect(mail.html_part.body).to include deputy_director.name

    expect(mail.text_part.body).to include pq.uin
    expect(mail.text_part.body).to include pq.text
    expect(mail.text_part.body).to include pq.member_name
    expect(mail.text_part.body).to include pq.internal_deadline.to_s(:date)
    expect(mail.text_part.body).to include action_officer.name
    expect(mail.text_part.body).to include deputy_director.name

    expect(mail.to).to include deputy_director.email
  end

  it 'should not send an email if the deputy director email does not exist' do
    assignment = ActionOfficersPq.new(action_officer_id: action_officer2.id, pq_id: pq.id)
    result = subject.notify_dd(assignment)
    expect(result).to eq('Deputy Director has no email')
  end

  it 'should include "No deadline set" in email to DD if not set' do
    new_pq = Pq.create(uin: 'HL999', text: 'test question?', raising_member_id: 0, member_name: 'Henry Higgins', internal_deadline: nil, minister:minister, house_name:'commons' )

    assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: new_pq.id)
    result = subject.notify_dd(assignment)
    mail = ActionMailer::Base.deliveries.first
    expect(mail.html_part.body).to include 'No deadline set'
  end
end
