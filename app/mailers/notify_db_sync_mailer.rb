class NotifyDbSyncMailer < ApplicationMailer
  def notify_fail(error_message)
    set_template('c4d52018-add8-49a2-bb86-f74f05829293')
    set_personalisation(error_message:)
    set_email_reply_to(Settings.tech_support_email)
    mail(to: Settings.mail_tech_support)
  end
end
