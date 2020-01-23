require 'spec_helper'
describe NotifyDbSyncMailer, type: :mailer do
  describe 'notify_fail' do
    let(:mail) { described_class.notify_fail('error message') }

    it 'sets the template' do
      expect(mail.govuk_notify_template).to eq 'c4d52018-add8-49a2-bb86-f74f05829293'
    end

    it 'sets the To address of the email using the provided user' do
      expect(mail.to).to eq([Settings.mail_tech_support])
    end

    it 'sets the personalisation in the email' do
      expect(mail.govuk_notify_personalisation.keys)
        .to eq([:error_message])
    end
  end
end
