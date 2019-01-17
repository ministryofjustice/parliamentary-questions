module MailService
  module Pq
    module_function

    extend Base

    def commission_email(params)
      details_h =
        {
          method: 'commission_email',
          from: Settings.commission_mail_from,
          cc: params[:cc],
        }

      generate_email(details_h, base_h(params))
    end

    def notify_dd_email(params)
      generate_email({ method: 'notify_dd_email' }, base_h(params))
    end

    def acceptance_email(pq, ao)
=begin
      TODO: AS an INTERIM FIX, we're using the details_h code, rather than the simple call using base_h (with cc added)
      TODO: - this is owing to time pressure on the live system, a card has been added to Pivotal to Refactor this code. ? cc to be added to base_h ?

      params = Presenters::Email.cc_list_hash(pq, ao)

      generate_email({ method: 'acceptance_email' }, base_h(params))
=end
      params = Presenters::Email.cc_list_hash(pq, ao)
      details_h =
        {
          method: 'acceptance_email',
          cc: params[:cc],
        }

      generate_email(details_h, base_h(params))
    end

    def acceptance_reminder_email(pq, ao)
=begin
      params = Presenters::Email.default_hash(pq, ao)

      generate_email({ method: 'acceptance_reminder_email' }, base_h(params))
=end

      params = Presenters::Email.cc_list_hash(pq, ao)
      details_h =
        {
          method: 'acceptance_reminder_email',
          cc: params[:cc],
        }

      generate_email(details_h, base_h(params))
    end

    def draft_reminder_email(pq, ao)
=begin
      params = Presenters::Email.cc_list_hash(pq, ao)

      generate_email({ method: 'draft_reminder_email' }, base_h(params))
=end

      params = Presenters::Email.cc_list_hash(pq, ao)
      details_h =
        {
          method: 'draft_reminder_email',
          cc: params[:cc],
        }

      generate_email(details_h, base_h(params))
    end

    def watchlist_email(params)
      details_h =
        {
          method: 'watchlist_email',
          cc: params[:cc],
          params: params.merge({ date: Date.today.to_s(:date) })
        }

      generate_email(details_h, base_h(params))
    end

    def early_bird_email(params)
      details_h =
        {
          method: 'early_bird_email',
          cc: params[:cc],
          params: params.merge({ date: Date.today.to_s(:date) })
        }

      generate_email(details_h, base_h(params))
    end

    private_class_method

    def base_h(params)
      {
        mailer: 'PqMailer',
        to: params[:email],
        from: default_sender,
        reply_to: default_reply_to,
        params: params
      }
    end
  end
end
