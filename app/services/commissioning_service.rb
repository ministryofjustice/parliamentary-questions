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
      pq = build_pq(form)
      pq.action_officers_pqs << form.action_officer_id.map do |ao_id|
        ActionOfficersPq.create!(
          pq_id: pq.id,
          action_officer_id: ao_id
        )
      end

      pq.save!
      PQProgressChangerService.new.update_progress(pq)

      pq.action_officers_pqs.each do |ao_pq|
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
      PqMailer.commission_email(email_template(pq, ao).merge(
        email: ao.emails,
        token: token,
        entity: entity
      )).deliver
    end

    if dd && dd.email
      internal_deadline = pq.internal_deadline ? pq.internal_deadline.to_s(:date) :
                                                'No deadline set'

      LogStuff.tag(:mail_notify) do
        PqMailer.notify_dd_email(email_template(pq, ao).merge(
          email: dd.email,
          dd_name: dd.name,
          internal_deadline: internal_deadline
        )).deliver
      end
    end
  end

  private

  def email_template(pq, ao)
    {
      :uin => pq.uin,
      :question => pq.question,
      :ao_name => ao.name,
      :member_name => pq.member_name,
      :house => pq.house_name,
      :answer_by => pq.minister.name
    }
  end
end
