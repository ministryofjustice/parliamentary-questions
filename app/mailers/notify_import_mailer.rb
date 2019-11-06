class NotifyImportMailer < GovukNotifyRails::Mailer
  def notify_fail(error_message)
    set_template('586dd10e-8987-4754-b653-9cacd3763d19')
    set_personalisation(
      environment: '',
      error_message: error_message
    )
    mail(to: Settings.mail_tech_support)
  end

  def notify_success(report)
    set_template('7858c6b6-774e-47f5-80c2-bea221805bb7')
    set_personalisation(
      environment: '',
      total_questions: report[:total],
      questions_created: report[:created],
      questions_updated: report[:updated]
    )
    mail(to: Settings.mail_tech_support)
  end
end
