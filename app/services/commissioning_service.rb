class CommissioningService
  def initialize(tokenService = nil, current_time = nil)
    @tokenService = tokenService || TokenService.new
    @current_time = current_time || DateTime.now
  end

  def commission(assignment)
    raise 'Action Officer is not selected' if assignment.action_officer_id.nil?
    raise 'Question is not selected' if assignment.pq_id.nil?

    action_officers_pq = ActionOfficersPq.create(action_officer_id: assignment.action_officer_id, pq_id: assignment.pq_id)
    ao = assignment.action_officer
    pq = assignment.pq

    PQProgressChangerService.new.update_progress(pq)

    path = "/assignment/#{pq.uin.encode}"
    entity = "assignment:#{action_officers_pq.id}"

    token_expires = @current_time.end_of_day + 3.days
    token = @tokenService.generate_token(path, entity, token_expires)

    $statsd.increment "#{StatsHelper::TOKENS_GENERATE}.commission"

    template = build_template_hash(pq,ao)
    template.merge!({
                      :email => ao.emails,
                      :entity => entity,
                      :token => token
                    })

    LogStuff.tag(:mailer_commission) do
      PqMailer.commission_email(template).deliver
    end

    return {token: token, assignment_id: action_officers_pq.id}
  end

  def notify_dd(assignment)
    raise 'Action Officer is not selected' if assignment.action_officer_id.nil?
    raise 'Question is not selected' if assignment.pq_id.nil?

    ao = assignment.action_officer
    pq = assignment.pq
    dd = DeputyDirector.find_by(id: ao.deputy_director_id)

    return 'Deputy Director has no email' if dd.email.blank?

    template = build_template_hash(pq, ao)
    template.merge!({
                        :email => dd.email,
                        :dd_name => dd.name,
                        :internal_deadline => 'No deadline set'
                    })
    if pq.internal_deadline
      template[:internal_deadline] = pq.internal_deadline.to_s(:date)
    end

    LogStuff.tag(:mail_notify) do
      PqMailer.notify_dd_email(template).deliver
    end
  end

private

  def build_template_hash(pq,ao)
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
