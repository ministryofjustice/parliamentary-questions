class ImportMailer < PQBaseMailer
  def notify_fail(mail_data)
    @err_msg = mail_data.params

    mail(
      mail_data.addressees.merge({ 
        subject:  prefix('API import failed')
      })
    )
  end

  def notify_success(mail_data)
    @report = mail_data.params

    mail(
      mail_data.addressees.merge({ 
        subject:  prefix('API import succeeded')
      })
    )
  end
end
