require 'spec_helper'

describe MailService::DbSync do
  let(:service)  { MailService::DbSync  }

  it '#notify_fail - should create a db sync notify fail email record' do
    service.notify_fail('sync error message')

    expect(Email.first.attributes).to include({
      'mailer'            => 'DbSyncMailer',
      'method'            => 'notify_fail',
      'params'            => 'sync error message',
      'from'              => Settings.mail_from,
      'to'                => 'pqsupport@digital.justice.gov.uk',
      'cc'                => nil,
      'reply_to'          => Settings.mail_reply_to,
      'num_send_attempts' => 0,
      'status'            => 'new',
    })
  end  
end