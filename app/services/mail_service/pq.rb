module MailService
  module Pq
    module_function
    extend Base

    def commission_email(params)
      details_h =
      {
        method: 'commission_email',
        from:   Settings.commission_mail_from,
      }

      generate_email(details_h, base_h(params))
    end

    def notify_dd_email(params)
      generate_email({ method: 'notify_dd_email' }, base_h(params))
    end

    def acceptance_email(pq, ao)
      params = Presenters::Email.cc_list_hash(pq, ao)

      generate_email({ method: 'acceptance_email' }, base_h(params))
    end

    def acceptance_reminder_email(pq, ao)
      params = Presenters::Email.default_hash(pq, ao)

      generate_email({ method: 'acceptance_reminder_email' }, base_h(params))
    end

    def draft_reminder_email(pq, ao)
      params = Presenters::Email.cc_list_hash(pq, ao)

      generate_email({ method: 'draft_reminder_email' }, base_h(params))
    end

    def watchlist_email(params)
      details_h = 
      {
        method: 'watchlist_email',
        cc:     params[:cc],
        params: params.merge({ date: Date.today.to_s(:date)})
      }

      generate_email(details_h, base_h(params))
    end

    private_class_method

    def base_h(params)
      {
        mailer:   'PqMailer',
        to:       params[:email],
        from:     default_sender,
        reply_to: default_reply_to,
        params:   params
      }
    end
  end
end