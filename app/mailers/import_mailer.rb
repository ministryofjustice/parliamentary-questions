class ImportMailer < PQBaseMailer
  default from: Settings.mail_from

  def notify_fail(err_msg)
    @err_msg = err_msg
    mail(to: Settings.mail_tech_support, subject: prefix('API import failed'))
  end

  def notify_success(report)
    @report = report
    mail(to: Settings.mail_tech_support, subject: prefix('API import succeeded'))
  end

  private

  def prefix(subject)
    "[#{app_env}][#{app_version}] #{subject}"
  end

  def app_version
    ENV.fetch('APPVERSION', 'version-unknown')
  end

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
