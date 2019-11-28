class NotifyImportMailer < GovukNotifyRails::Mailer
  def notify_fail(error_message)
    set_template('586dd10e-8987-4754-b653-9cacd3763d19')
    set_personalisation(
      environment: app_env,
      error_message: error_message
    )
    mail(to: Settings.mail_tech_support)
  end

  def notify_success(report)
    set_template('7858c6b6-774e-47f5-80c2-bea221805bb7')
    set_personalisation(
      environment: app_env,
      total_questions: report[:total],
      questions_created: report[:created],
      questions_updated: report[:updated]
    )
    mail(to: Settings.mail_tech_support)
  end

  private

  def app_env
    case ENV['SENDING_HOST']
    when 'trackparliamentaryquestions.service.gov.uk'
      'production'
    when 'staging.pq.dsd.io'
      'staging'
    when 'dev.pq.dsd.io'
      'dev'
    else
      'env-unknown'
    end
  end
end
