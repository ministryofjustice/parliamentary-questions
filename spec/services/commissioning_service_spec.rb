require 'spec_helper'

describe 'CommissioningService' do
  let(:minister) {build(:minister)}
  let(:deputy_director) { create(:deputy_director, name: 'dd name', email: 'dd@dd.gov', id: 1+rand(10))}
  let(:action_officer) { create(:action_officer, name: 'ao name 1', email: 'ao@ao.gov', deputy_director_id: deputy_director.id) }
  let(:pq) { create(:Pq, uin: 'HL789', question: 'test question?', member_name: 'Henry Higgins', internal_deadline:'01/01/2014 10:30', minister:minister, house_name:'commons' ) }

  let(:deputy_director2) { create(:deputy_director, name: 'dd name', email: '', id: 1+rand(10))}
  let(:action_officer2) { create(:action_officer, name: 'ao name 1', email: 'ao@ao.gov', deputy_director_id: deputy_director2.id) }

  progress_seed


  before(:each) do
    @comm_service = CommissioningService.new
    ActionMailer::Base.deliveries = []
  end

  it 'should return the assignment id and inserts the data' do
    assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

    result = @comm_service.send(assignment)

    result.should_not be nil
    result[:assignment_id].should_not be nil

    ActionOfficersPq.where(action_officer_id: action_officer.id, pq_id: pq.id).first.should_not be nil
  end

  it 'should have generated a valid token' do
    assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

    result = @comm_service.send(assignment)

    token = Token.where(entity: "assignment:#{result[:assignment_id]}", path: '/assignment/HL789').first

    token.should_not be nil
    token.id.should_not be nil
    token.token_digest.should_not be nil

    token_expires = DateTime.now.midnight.change({:offset => 0}) + 3.days
    token.expire.should eq(token_expires)

  end

  it 'should send an email with the right data' do
    assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

    result = @comm_service.send(assignment)
    sentToken = result[:token]

    mail = ActionMailer::Base.deliveries.first


    token_param = {token: sentToken}.to_query
    entity = {entity: "assignment:#{result[:assignment_id]}"}.to_query
    url = "/assignment/HL789"

    mail.html_part.body.should include pq.question
    mail.html_part.body.should include action_officer.name
    mail.html_part.body.should include url
    mail.html_part.body.should include token_param
    mail.html_part.body.should include entity

    mail.text_part.body.should include pq.question
    mail.text_part.body.should include action_officer.name
    mail.text_part.body.should include url
    mail.text_part.body.should include token_param
    mail.text_part.body.should include entity

    mail.to.should include action_officer.email

  end


  it 'should set the progress to Allocated Pending' do
    assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

    result = @comm_service.send(assignment)

    result.should_not be nil

    assignment_id = result[:assignment_id]
    assignment_id.should_not be nil

    assignment = ActionOfficersPq.find(assignment_id)

    pq = Pq.find(assignment.pq_id)
    pq.progress.name.should  eq(Progress.NO_RESPONSE)

  end


  it 'should not set the progress to Allocated Pending if the question is already accepted' do
    assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

    pq.progress_id = Progress.accepted.id
    pq.save

    @comm_service.send(assignment)

    pq = Pq.find(assignment.pq_id)
    pq.progress.name.should  eq(Progress.ACCEPTED)

  end

  it 'should not set the progress to Allocated Pending if the question is rejected' do
    assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

    pq.progress_id = Progress.rejected.id
    pq.save

    @comm_service.send(assignment)

    pq = Pq.find(assignment.pq_id)
    pq.progress.name.should  eq(Progress.REJECTED)

  end





  it 'should raise an error if the action_officer.id is null' do
    assignment = ActionOfficersPq.new(pq_id: pq.id)
    expect {
      @comm_service.send(assignment)
    }.to raise_error 'Action Officer is not selected'
  end

  it 'should raise an error if the pq_id is null' do
    assignment = ActionOfficersPq.new(action_officer_id: action_officer.id)
    expect {
      @comm_service.send(assignment)
    }.to raise_error 'Question is not selected'
  end


  it 'should send an email to the deputy director the right data' do

    assignment = ActionOfficersPq.new(action_officer_id: action_officer.id, pq_id: pq.id)

    result = @comm_service.notify_dd(assignment)

    mail = ActionMailer::Base.deliveries.first

   # entity = {entity: "assignment:#{result[:assignment_id]}"}.to_query

   # url = "/assignment/HL789"


    mail.html_part.body.should include pq.uin
    mail.html_part.body.should include pq.question
    mail.html_part.body.should include pq.member_name
    mail.html_part.body.should include pq.internal_deadline.strftime('%d/%m/%Y')
    mail.html_part.body.should include action_officer.name
    mail.html_part.body.should include deputy_director.name


    mail.text_part.body.should include pq.uin
    mail.text_part.body.should include pq.question
    mail.text_part.body.should include pq.member_name
    mail.text_part.body.should include pq.internal_deadline.strftime('%d/%m/%Y')
    mail.text_part.body.should include action_officer.name
    mail.text_part.body.should include deputy_director.name

    mail.to.should include deputy_director.email

  end

  it 'should not send an email if the deputy director email does not exist' do

    assignment = ActionOfficersPq.new(action_officer_id: action_officer2.id, pq_id: pq.id)

    result = @comm_service.notify_dd(assignment)

    result.should eq('Deputy Director has no email')

  end
end