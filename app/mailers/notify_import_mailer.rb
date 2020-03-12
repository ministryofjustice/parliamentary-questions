class NotifyImportMailer < GovukNotifyRails::Mailer
  def notify_fail(error_message)
    # Setup GOV.UK Notify mailer variables
    set_template('586dd10e-8987-4754-b653-9cacd3763d19')
    set_personalisation(
      environment: ENV['RAILS_ENV'],
      error_message: error_message
    )
    set_email_reply_to(Settings.tech_support_email)
    mail(to: Settings.mail_tech_support)
  end

  def notify_success(report)
    # Setup GOV.UK Notify mailer variables
    set_template('7858c6b6-774e-47f5-80c2-bea221805bb7')
    set_personalisation(
      environment: ENV['RAILS_ENV'],
      total_questions: report[:total],
      questions_created: report[:created],
      questions_updated: report[:updated]
    )
    set_email_reply_to(Settings.tech_support_email)
    mail(to: Settings.mail_tech_support)
  end
end
