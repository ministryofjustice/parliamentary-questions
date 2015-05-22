class CommissioningService
  include Rails.application.routes.url_helpers
  AO_TOKEN_LIFETIME = 3

  def initialize(tokenService = nil, current_time = nil)
    @tokenService = tokenService || TokenService.new
    @current_time = current_time || DateTime.now
  end

  def commission(form)
    raise ArgumentError, "form is invalid" unless form.valid?

    ActiveRecord::Base.transaction do
      pq     = build_pq(form)
      ao_pqs = form.action_officer_id.map do |ao_id|
        ActionOfficersPq.create!(
          pq_id: pq.id,
          action_officer_id: ao_id
        )
      end

      pq.action_officers_pqs << ao_pqs
      pq.update_state!

      ao_pqs.each do |ao_pq|
        notify_assignment(ao_pq)
      end
      pq
    end
  end

  private

  def build_pq(form)
    pq                    = Pq.find(form.pq_id)
    pq.minister_id        = form.minister_id
    pq.policy_minister_id = form.policy_minister_id
    pq.date_for_answer    = form.date_for_answer
    pq.internal_deadline  = form.internal_deadline
    pq
  end

  def notify_assignment(ao_pq)
    ao      = ao_pq.action_officer
    pq      = ao_pq.pq
    path    = assignment_path(uin: pq.uin.encode)
    entity  = "assignment:#{ao_pq.id}"
    expires = @current_time.end_of_day + AO_TOKEN_LIFETIME.days
    token   = @tokenService.generate_token(path, entity, expires)
    dd      = ao.deputy_director

    $statsd.increment "#{StatsHelper::TOKENS_GENERATE}.commission"

    LogStuff.tag(:mailer_commission) do
      mail_params =
        Presenters::Email.default_hash(pq, ao).merge(
          token: token,
          entity: entity
        )

      MailService::Pq.commission_email(mail_params)
    end
    
  end
end
