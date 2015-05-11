module MailService
  module Base
    module_function

    protected

    def generate_email(details_h, base_h)
      attributes = base_h.merge(details_h)

      Email.create(attributes)
    end

    def default_sender
      @sender ||= Settings.mail_from
    end

    def default_reply_to
      @reply_to ||= Settings.mail_reply_to
    end
  end
end
