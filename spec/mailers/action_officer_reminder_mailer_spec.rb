require 'spec_helper'

describe 'ActionOfficerReminderMailer' do
  let(:ao) { create(:action_officer,  name: 'ao name 1', email: 'ao@ao.gov') }
  let(:minister_1) { create(:minister, name: 'Mr Name1 for Test') }

  before(:each) do
    ActionMailer::Base.deliveries = []
    @pq = create(:pq, uin: 'HL789', question: 'test question?', member_name:'Asking MP', minister_id: minister_1.id, house_name: 'House of Lords')
    @ao_pq = ActionOfficersPq.new(action_officer_id: ao.id, pq_id: @pq.id)

    @template = Hash.new
    @template[:ao_name] = ao.name
    @template[:email] = ao.emails
    @template[:uin] = @pq.uin
    @template[:question] = @pq.question
    @template[:member_name] = @pq.member_name
    @template[:house_name] = @pq.house_name
  end

  describe 'Accept reminder' do
    describe 'deliver' do
      it 'should include house, member name and uin from PQ and AO name' do
        PqMailer.acceptance_reminder_email(@template).deliver

        mail = ActionMailer::Base.deliveries.first

        expect(mail.html_part.body).to include @pq.member_name
        expect(mail.html_part.body).to include @pq.house_name
        expect(mail.html_part.body).to include @pq.uin
        expect(mail.html_part.body).to include ao.name

        expect(mail.text_part.body).to include @pq.member_name
        expect(mail.text_part.body).to include @pq.house_name
        expect(mail.text_part.body).to include @pq.uin
        expect(mail.text_part.body).to include ao.name
      end
    end
  end

  describe 'draft reminder' do
    describe 'deliver' do
      it 'should have URGENT in the subject' do
        PqMailer.acceptance_email(@pq, ao,true).deliver

        mail = ActionMailer::Base.deliveries.first
        expect(mail.to).to include ao.email
        expect(mail.subject).to include 'URGENT'
      end
    end
  end
end
