class NotifyDbSyncMailer < GovukNotifyRails::Mailer
  # def notify_fail(mail_data)
  #   @err_msg = mail_data.params
  #
  #   mail(
  #     mail_data.addressees.merge(
  #       subject: prefix('Staging DB sanitization failed')
  #     )
  #   )
  # end

  def notify_fail(error_message)
    set_template('c4d52018-add8-49a2-bb86-f74f05829293')
    set_personalisation(
      error_message: error_message
    )
    mail(to: Settings.mail_tech_support)
  end
end
