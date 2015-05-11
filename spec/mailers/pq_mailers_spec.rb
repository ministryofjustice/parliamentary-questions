require 'spec_helper'

describe PqMailer do

  describe 'commission_email' do

    before(:each) do
      pq = FactoryGirl.create :pq
      @template_params = {
        :uin                  => pq.uin,
        :question             => pq.question,
        :ao_name              => "Colin Bruce",
        :member_constituency  => "Kingston upon Hull North",
        :member_name          => "Diana Johnson",
        :house_name           => "House of Commons",
        :answer_by            => "Damian Green (MP)",
        :internal_deadline    => 3.days.from_now,
        :date_to_parliament   => 5.days.from_now,
        :email                => "colin.bruce@digital.justice.gov.uk",
        :token                => "KL7g57Y-7ZFgBBGvWq9o",
        :entity               => "assignment:4"}
    end
    describe 'deliver' do
      it 'should have correct addressing info' do
        MailService::Pq.commission_email(@template_params)
        MailWorker.new.run!
        
        mail = ActionMailer::Base.deliveries.first
        expect(mail.to).to eq ["colin.bruce@digital.justice.gov.uk"]
        expect(mail.from).to eq ["no-reply@trackparliamentaryquestions.service.gov.uk"]
        expect(mail.reply_to).to eq ["pqs@justice.gsi.gov.uk"]

        expect(mail.to_s).to include 'From: PQ Team <no-reply@trackparliamentaryquestions.service.gov.uk>'
        expect(mail.to_s).to include 'Reply-To: pqs@justice.gsi.gov.uk'
      end
    end
  end

end

