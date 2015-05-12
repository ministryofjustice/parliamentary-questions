module MailService
  module Import
    module_function
    extend Base

    def notify_fail(err_msg)
      details_h = 
      {
        method: 'notify_fail',
        params: err_msg,
      }

      generate_email(details_h, base_h)
    end

    def notify_success(report)
      details_h = 
      {
        method: 'notify_success',
        params: report,
      }

      generate_email(details_h, base_h)
    end

    private_class_method

    def base_h
      @base_h ||=
        {
          mailer:   'ImportMailer',
          from:     default_sender,
          to:       Settings.mail_tech_support,
          reply_to: default_reply_to
        }
    end
  end
end
