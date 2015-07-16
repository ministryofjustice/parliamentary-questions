class PqMailer < PQBaseMailer
  def commission_email(mail_data)
    mail_with_subject(
      "You have been allocated PQ #{mail_data.params[:uin]}",
      mail_data
    )
  end

  def acceptance_email(mail_data)
    mail_with_subject("You accepted PQ #{mail_data.params[:uin]}", mail_data)
  end

  def acceptance_reminder_email(mail_data)
    mail_with_subject(
      "URGENT REMINDER: you need to accept or reject PQ #{mail_data.params[:uin]}",
      mail_data
    )
  end

  def draft_reminder_email(mail_data)
    mail_with_subject(
      "URGENT REMINDER: please send your draft response to PQ #{mail_data.params[:uin]}",
      mail_data
    )
  end

  def watchlist_email(mail_data)
    mail_with_subject('PQs allocated today', mail_data)
  end

  def early_bird_email(mail_data)
    mail_with_subject('PQs to be allocated today', mail_data)
  end

  private

  def mail_with_subject(subject, mail_data)
    @template_params = mail_data.params

    mail(
      mail_data.addressees.merge({
        subject:  subject
      })
    )
  end
end
