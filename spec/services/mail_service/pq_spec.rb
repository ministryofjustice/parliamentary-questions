require 'spec_helper'

describe MailService::Pq do
  let(:service)  { MailService::Pq                    }
  let(:email_to) { 'to@domain.com'                    }
  let(:params)   { { email: email_to, cc: email_to }  }
  let(:ao)       { double ActionOfficer               }
  let(:pq)       { double Pq                          }

  it '#commission_email - should create a commission email db record' do
    service.commission_email(params)

    expect(Email.first.attributes).to include({
      'mailer'            => 'PqMailer',
      'method'            => 'commission_email',
      'params'            => params,
      'from'              => Settings.commission_mail_from,
      'to'                => email_to,
      'reply_to'          => Settings.mail_reply_to,
    })
  end

  it '#notify_dd_email - should create a dd notification email db record' do
    service.notify_dd_email(params)

    expect(Email.first.attributes).to include({
      'mailer'            => 'PqMailer',
      'method'            => 'notify_dd_email',
      'params'            => params,
      'from'              => Settings.mail_from,
      'to'                => email_to,
      'reply_to'          => Settings.mail_reply_to,
    })
  end  

  it '#acceptance_email - should create an acceptance email db record' do
    allow(Presenters::Email).to receive(:cc_list_hash).with(pq, ao).and_return(params)

    service.acceptance_email(pq, ao)

    expect(Email.first.attributes).to include({
      'method' => 'acceptance_email',
      'params' => params
    })
  end 

  it '#acceptance_reminder_email - should create an acceptance reminder email db record' do
    allow(Presenters::Email).to receive(:default_hash).with(pq, ao).and_return(params)

    service.acceptance_reminder_email(pq, ao)

    expect(Email.first.attributes).to include({
      'method' => 'acceptance_reminder_email',
      'params' => params
    })
  end   

  it '#draft_reminder_email - should create a draft reminder email db record' do
    allow(Presenters::Email).to receive(:cc_list_hash).with(pq, ao).and_return(params)

    service.draft_reminder_email(pq, ao)

    expect(Email.first.attributes).to include({
      'method' => 'draft_reminder_email',
      'params' => params
    })
  end 

  it '#watchlist_email - should create a watchlist email db record' do
    Timecop.freeze(Date.today) do
      service.watchlist_email(params)

      expect(Email.first.attributes).to include({
        'method' => 'watchlist_email',
        'cc'     => email_to,
        'params' => params.merge({ date: Date.today.to_s(:date)})
      })
    end
  end 
end