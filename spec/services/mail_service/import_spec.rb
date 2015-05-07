require 'spec_helper'

describe MailService::Import do
  let(:service)  { MailService::Import }

  it '#notify_fail - should create a import notify fail email record' do
    service.notify_fail('import error message')

    expect(Email.first.attributes).to include({
      'mailer'            => 'ImportMailer',
      'method'            => 'notify_fail',
      'params'            => 'import error message',
      'from'              => Settings.mail_from,
      'to'                => 'pqsupport@digital.justice.gov.uk',
      'cc'                => nil,
      'reply_to'          => Settings.mail_reply_to,
      'num_send_attempts' => 0,
      'status'            => 'new',
    })
  end

  it '#notify_success - should create a import notify success email record' do
    report = 
    {
      total:    18,
      created:  15,
      updated:  3,
      errors:   {}
    }

    service.notify_success(report)

    expect(Email.first.attributes).to include({
      'mailer'            => 'ImportMailer',
      'method'            => 'notify_success',
      'params'            => report,
      'from'              => Settings.mail_from,
      'to'                => 'pqsupport@digital.justice.gov.uk',
      'cc'                => nil,
      'reply_to'          => Settings.mail_reply_to,
      'num_send_attempts' => 0,
      'status'            => 'new',
    })
  end
end