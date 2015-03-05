class ImportMailer < PQBaseMailer
  default from: Settings.mail_from 

  def notify_fail(err_msg)
    @err_msg = err_msg
    mail(to: Settings.mail_tech_support, subject: 'API import failed')
  end

  def notify_success(report)
    @report = report
    mail(to: Settings.mail_tech_support, subject: 'API import succeeded')
  end
end