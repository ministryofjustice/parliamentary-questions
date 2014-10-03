class CommissioningService

  def initialize(tokenService = TokenService.new)
    @tokenService = tokenService
  end

  def send(assignment)
    raise 'Action Officer is not selected' if assignment.action_officer_id.nil?
    raise 'Question is not selected' if assignment.pq_id.nil?

    action_officers_pq = ActionOfficersPq.create(action_officer_id: assignment.action_officer_id, pq_id: assignment.pq_id, accept: false, reject: false)
    ao = get_action_officer(assignment)
    pq = get_pq_by(assignment)

    # no accepted/rejected -> change the state to allocated_pending
    update_pq_progress(pq)

    path = "/assignment/#{pq.uin.encode}"
    entity = "assignment:#{action_officers_pq.id}"

    token_expires = DateTime.now.midnight.change({:offset => 0}) + 3.days
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

    ao = get_action_officer(assignment)
    pq = get_pq_by(assignment)
    dd = DeputyDirector.find_by(id: ao.deputy_director_id)

    return 'Deputy Director has no email' if dd.email.blank?

    template = build_template_hash(pq, ao)
    template.merge!({
                        :email => dd.email,
                        :dd_name => dd.name,
                        :internal_deadline => 'No deadline set'
                    })
    if pq.internal_deadline
      template[:internal_deadline] = pq.internal_deadline.strftime('%d/%m/%Y')
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
  def update_pq_progress(pq)
    if !(pq.is_in_progress?(Progress.accepted) || pq.is_in_progress?(Progress.rejected))
      pro = Progress.no_response
      pq.update progress_id: pro.id
    end
  end
  def get_pq_by(assignment)
    Pq.find_by(id: assignment.pq_id)
  end
  def get_action_officer(assignment)
    ActionOfficer.find(assignment.action_officer_id)
  end
end