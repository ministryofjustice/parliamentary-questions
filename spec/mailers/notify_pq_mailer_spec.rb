require 'spec_helper'
# TODO add other mail types. Do we need to test all the personalisation??
describe NotifyPqMailer, type: :mailer do
  describe 'acceptance_email' do
    let(:pq)    { create :pq }
    let(:ao)    { create :action_officer }
    let(:mail)  { described_class.acceptance_email(pq: pq, action_officer: ao) }

    it 'sets the template' do
      expect(mail.govuk_notify_template).to eq 'b8b325ad-a00a-4ae9-8830-6386f04adbca'
    end

    it 'sets the To address of the email using the provided user' do
      expect(mail.to).to eq([ao.email])
    end

    context 'optional variables are not set' do
      it 'sets the personalisation in the email' do
        expect(mail.govuk_notify_personalisation).
          to eq(
            uin: pq.uin,
            ao_name: ao.name,
            question: pq.question,
            member_name: '',
            house_name: '',
            member_constituency: '',
            answer_by: '',
            internal_deadline: '',
            date_to_parliament: '',
            cc_list: ao.group_email,
            mail_reply_to: 'pqs@justice.gsi.gov.uk',
          )
      end
    end

    context 'optional variables are all set' do
      it 'sets the personalisation in the email' do
        minister = FactoryBot.create(:minister)
        pq.update_attributes(member_constituency: 'Kingston upon Hull North',
                              member_name: 'Diana Johnson',
                              house_name: 'House of Commons',
                              minister: minister)
        expect(mail.govuk_notify_personalisation).
          to eq(
            uin: pq.uin,
            ao_name: ao.name,
            question: pq.question,
            member_name: "Asked by Diana Johnson",
            house_name: "House of Commons",
            member_constituency: "Constituency Kingston upon Hull North",
            answer_by: minister.name,
            internal_deadline: '',
            date_to_parliament: '',
            cc_list: ao.group_email,
            mail_reply_to: 'pqs@justice.gsi.gov.uk',
          )
      end
    end
  end
end
