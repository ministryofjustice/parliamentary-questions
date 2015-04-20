class DbSyncMailer < PQBaseMailer
  default from: Settings.mail_from

  def notify_fail(err_msg)
    @err_msg = err_msg
    mail(to: Settings.mail_tech_support, subject: prefix('Staging DB sanitization failed'))
  end
end
