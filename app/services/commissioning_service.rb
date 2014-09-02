class CommissioningService

  def initialize(tokenService = TokenService.new)
    @tokenService = tokenService
  end

  def send(assignment)
    raise 'Action Officer is not selected' if assignment.action_officer_id.nil?
    raise 'Question is not selected' if assignment.pq_id.nil?

    actionOfficersPq = ActionOfficersPq.create(action_officer_id: assignment.action_officer_id, pq_id: assignment.pq_id, accept: false, reject: false)
    ao = ActionOfficer.find(assignment.action_officer_id)
    pq = Pq.find_by(id: assignment.pq_id)


    # no accepted/rejected -> change the state to allocated_pending
    if !(pq.is_in_progress?(Progress.accepted) || pq.is_in_progress?(Progress.rejected) )
      pro = Progress.no_response
      pq.update progress_id: pro.id
    end


    path = '/assignment/' + pq.uin.encode
    entity = "assignment:#{actionOfficersPq.id}"

    token_expires = DateTime.now.midnight.change({:offset => 0}) + 3.days
    token = @tokenService.generate_token(path, entity, token_expires)

    $statsd.increment "#{StatsHelper::TOKENS_GENERATE}.commission"

    template = build_template_hash(pq,ao)
    template.merge!({
                      :email => ao.emails,
                      :entity => entity,
                      :token => token
                    })

    PqMailer.commission_email(template).deliver

    return {token: token, assignment_id: actionOfficersPq.id}
  end
  def notify_dd(assignment)
    raise 'Action Officer is not selected' if assignment.action_officer_id.nil?
    raise 'Question is not selected' if assignment.pq_id.nil?

    ao = ActionOfficer.find(assignment.action_officer_id)
    pq = Pq.find_by(id: assignment.pq_id)
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

    PqMailer.notify_dd_email(template).deliver

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