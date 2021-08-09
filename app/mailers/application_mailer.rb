class ApplicationMailer < GovukNotifyRails::Mailer
  default from: 'noreply@digital.justice.gov.uk'
  layout 'mailer'
end
