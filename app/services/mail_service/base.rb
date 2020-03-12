module MailService
  module Base
    extend self

    protected

    def generate_email(details_h, base_h)
      attributes = base_h.merge(details_h)

      Email.create(attributes)
    end

    def default_sender
      @default_sender ||= Settings.mail_from
    end

    def default_reply_to
      @default_reply_to ||= Settings.mail_reply_to
    end
  end
end