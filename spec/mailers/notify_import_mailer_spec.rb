require 'spec_helper'
describe NotifyImportMailer, type: :mailer do
  describe 'notify_fail' do
    let(:mail) { described_class.notify_fail(StandardError) }

    it 'sets the template' do
      expect(mail.govuk_notify_template).to eq '586dd10e-8987-4754-b653-9cacd3763d19'
    end

    it 'sets the To address of the email using the provided user' do
      expect(mail.to).to eq([Settings.mail_tech_support])
    end

    it 'sets the personalisation in the email' do
      expect(mail.govuk_notify_personalisation)
        .to eq(
          environment: 'env-unknown',
          error_message: StandardError
        )
    end
  end

  describe 'notify_success' do
    let(:report) do
      {
        total: 4,
        created: 3,
        updated: 0
      }
    end
    let(:mail) { described_class.notify_success(report) }

    it 'sets the template' do
      expect(mail.govuk_notify_template).to eq '7858c6b6-774e-47f5-80c2-bea221805bb7'
    end

    it 'sets the To address of the email using the provided user' do
      expect(mail.to).to eq([Settings.mail_tech_support])
    end

    it 'sets the personalisation in the email' do
      expect(mail.govuk_notify_personalisation)
        .to eq(
          environment: 'env-unknown',
          total_questions: 4,
          questions_created: 3,
          questions_updated: 0
        )
    end
  end
end
