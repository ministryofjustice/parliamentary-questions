require 'spec_helper'

describe PQBaseMailer do

  context "logging" do

    let(:pq)      { FactoryGirl.create :pq }

    let(:template_params) do
      {
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
        :entity               => "assignment:4"
      }
    end


    it 'should log successful message when successful' do
      expect(LogStuff).to receive(:info).with(:mail_successful)
      expect_any_instance_of(Mail::Message).to receive(:deliver)
      PqMailer.commission_email(template_params).deliver
    end

    it 'should log errror message if exception raised' do
      expect(LogStuff).not_to receive(:info).with(:mail_successful)
      expect(LogStuff).to receive(:error).with(:mail_unsuccessful)
      expect_any_instance_of(Mail::Message).to receive(:deliver).and_raise(RuntimeError)
      expect {
        PqMailer.commission_email(template_params).deliver
      }.to raise_error(RuntimeError)
    end
  end


end