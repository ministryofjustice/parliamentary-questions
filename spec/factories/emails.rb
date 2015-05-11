# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :pq_email, class: Email do
    mailer                  'PqMailer'
    add_attribute(:method)  { 'commission_email'         }
    params                  { {uin: '1', ao: 'an ao'}    }
    from                    { Faker::Internet.safe_email }
    to                      { Faker::Internet.safe_email }
    cc                      { Faker::Internet.safe_email }
    reply_to                { Faker::Internet.safe_email }
    send_attempted_at       { Faker::Time.between(DateTime.yesterday, DateTime.now) }

    factory :pq_email_sent, class: Email do
      num_send_attempts     1
      status                'sent'
      sent_at               { Faker::Time.between(DateTime.yesterday, DateTime.now) }  
    end

    factory :pq_email_failed, class: Email do           
      num_send_attempts     2
      status                'failed'
    end
  end
end
