require 'spec_helper'

describe 'PQAcceptedMailer' do

  let(:ao) { create(:action_officer, name: 'ao name 1', email: 'ao@ao.gov') }
  let(:minister_1) { create(:minister, name: 'Mr Name1 for Test', email: 'test1@tesk.uk') }
  let(:minister_2) { create(:minister, name: 'Mr Name2 for Test', email: 'test2@tesk.uk') }
  let(:minister_simon) { create(:minister, name: 'Simon Hughes', email: 'simon@tesk.uk') }

  progress_seed

  before(:each) do
    ActionMailer::Base.deliveries = []
  end

  describe '#deliver' do
    it 'should set question and the email' do

      pq = create(:Pq, uin: 'HL789', question: 'test question?', minister_id: minister_1.id)
      PQAcceptedMailer.commit_email(pq, ao).deliver

      mail = ActionMailer::Base.deliveries.first
      mail.html_part.body.should include pq.question

      mail.text_part.body.should include pq.question
      mail.to.should include ao.email
    end

    it 'should set the right cc with minister and policy minister' do
      pq = create(:Pq, uin: 'HL789', question: 'test question?', minister_id: minister_1.id, policy_minister_id: minister_2.id)
      expectedCC = 'test1@tesk.uk;test2@tesk.uk'

      PQAcceptedMailer.commit_email(pq, ao).deliver

      mail = ActionMailer::Base.deliveries.first

      mail.text_part.body.should include expectedCC
      mail.html_part.body.should include CGI::escape(expectedCC)

    end

    it 'should set the right cc with minister the right people if the minister is Simon Huges' do
      pq = create(:Pq, uin: 'HL789', question: 'test question?', minister_id: minister_simon.id, policy_minister_id: minister_2.id)
      expectedCC = 'simon@tesk.uk;test2@tesk.uk;;Christopher.Beal@justice.gsi.gov.uk;Nicola.Calderhead@justice.gsi.gov.uk;thomas.murphy@JUSTICE.gsi.gov.uk'

      PQAcceptedMailer.commit_email(pq, ao).deliver

      mail = ActionMailer::Base.deliveries.first

      mail.text_part.body.should include expectedCC
      mail.html_part.body.should include CGI::escape(expectedCC)

    end


    it 'should add the people from the Actionlist to the CC on the draft email link' do

      create(:actionlist_member, name: 'A1', email: 'a1@a1.com', deleted: false)
      create(:actionlist_member, name: 'A2', email: 'a2@a2.com', deleted: false)
      create(:actionlist_member, name: 'A3', email: 'a3@a3.com', deleted: true)

      pq = create(:Pq, uin: 'HL789', question: 'test question?', minister_id: minister_1.id, policy_minister_id: minister_2.id)
      expectedCC = 'test1@tesk.uk;test2@tesk.uk;;a1@a1.com;a2@a2.com'

      PQAcceptedMailer.commit_email(pq, ao).deliver

      mail = ActionMailer::Base.deliveries.first

      mail.text_part.body.should include expectedCC
      mail.html_part.body.should include CGI::escape(expectedCC)

    end


    it 'should contain the name of the minister and the name of the policy minister' do
      pq = create(:Pq, uin: 'HL789', question: 'test question?', minister_id: minister_1.id, policy_minister_id: minister_2.id)

      PQAcceptedMailer.commit_email(pq, ao).deliver

      mail = ActionMailer::Base.deliveries.first

      mail.text_part.body.should include minister_1.name
      mail.html_part.body.should include minister_1.name

      mail.text_part.body.should include minister_2.name
      mail.html_part.body.should include minister_2.name

    end



  end
end