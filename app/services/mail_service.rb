module MailService
  module_function

  def send_mail(email)
    mailer = email.mailer.constantize
    method = email.method.to_sym

    mail_data = 
      MailData.new(
        email.to, 
        email.from, 
        email.cc,
        email.reply_to,
        email.params
      )
      
    mailer.public_send(method, mail_data).deliver
    record_success(email)
  end

  def mail_to_send
    Email.waiting
  end

  def abandoned_mail
    Email.abandoned
  end

  def new_mail
    Email.new_only
  end

  def record_success(email)
    email.update(
      status: 'sent',
      sent_at: DateTime.now
    )
  end

  def record_attempt(email)
    email.update(
      status:            'sending',
      send_attempted_at: DateTime.now,
      num_send_attempts: email.num_send_attempts + 1
    )
  end

  def record_fail(email)
    email.update(status: 'failed')
  end

  def record_abandon(email)
    email.update(status: 'abandoned')
  end

  private_class_method

  MailData = 
    Struct.new(:to, :from, :cc, :reply_to, :params) do
      def addressees
        {
          to:       to,
          from:     from,
          cc:       cc,
          reply_to: reply_to
        }
      end
    end
end