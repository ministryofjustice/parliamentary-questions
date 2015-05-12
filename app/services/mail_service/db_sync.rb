module MailService
  module DbSync
    module_function
    extend Base

    def notify_fail(err_msg)
      details_h = 
      {
        mailer:   'DbSyncMailer',
        method:   'notify_fail',
        params:   err_msg,
        from:     default_sender,
        to:       Settings.mail_tech_support,
        reply_to: default_reply_to
      }

      generate_email(details_h, {})
    end
  end
end