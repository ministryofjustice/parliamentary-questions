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

    tomorrow_midnight = DateTime.now.midnight.change({:offset => 0}) + 1.days
    token = @tokenService.generate_token(path, entity, tomorrow_midnight)

    $statsd.increment "#{StatsHelper::TOKENS_GENERATE}.commission"

    template = Hash.new
    template[:name] = ao.name
    template[:entity] = entity
    template[:email] = ao.email
    template[:uin] = pq.uin
    template[:question] = pq.question
    template[:token] = token

    PqMailer.commit_email(template).deliver

    return {token: token, assignment_id: actionOfficersPq.id}
  end
end