require 'spec_helper'

describe MailService do
  let(:service)  { MailService               }
  let!(:default) { create(:pq_email)         }
  let!(:sent)    { create(:pq_email_sent)    }
  let!(:failed)  { create(:pq_email_failed)  }  

  it '#mail_to_send - returns email in new/failed states' do
    expect(service.mail_to_send).to eq [default, failed]
  end

  it '#abandoned_mail - returns mail in abandoned state' do
    failed.update(status: 'abandoned')

    expect(service.abandoned_mail).to eq [failed]
  end

  it '#new_mail - returns mail in new state' do
    default.update(status: 'new')

    expect(service.new_mail).to eq [default]
  end


  it '#record_attempt - updates db fields for a send attempt' do
    service.record_attempt(default)

    expect(default.status).to eq 'sending'
    expect(default.num_send_attempts).to eq 1
    expect(default.send_attempted_at - Time.now).to be < 1
  end

  it '#record_success - updates db fields for sent emails' do
    service.record_success(default)

    expect(default.status).to eq 'sent'
    expect(default.sent_at - Time.now).to be < 1
  end

  it '#record_fail - updates db fields for failed email delivery' do
    service.record_fail(default)

    expect(default.status).to eq 'failed'
  end

  it '#record_abandon - updates db fields for an abandoned email' do
    service.record_abandon(failed)

    expect(failed.status).to eq 'abandoned'
  end

  it '#send_mail - calls the relevant mailer to send a db record' do
    mail_data = 
      MailService::MailData.new(
        default.to, 
        default.from, 
        default.cc,
        default.reply_to,
        default.params
      )

    expect(PqMailer).to receive(:commission_email).with(mail_data).and_call_original
    expect(MailService).to receive(:record_success).with(default)
    service.send_mail(default)
  end
end

