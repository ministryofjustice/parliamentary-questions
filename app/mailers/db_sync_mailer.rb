class DbSyncMailer < PQBaseMailer
  def notify_fail(mail_data)
    @err_msg = mail_data.params

    mail(
      mail_data.addressees.merge({ 
        subject:  prefix('Staging DB sanitization failed')
      })
    )
  end
end
