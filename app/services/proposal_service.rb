class ProposalService
  # include Rails.application.routes.url_helpers
  # AO_TOKEN_LIFETIME = 3

  # def initialize(token_service = nil, current_time = nil)
  #   @token_service = token_service || TokenService.new
  #   @current_time = current_time || DateTime.now.utc
  # end

  def propose(form)
    raise ArgumentError, 'form is invalid' unless form.valid?

    ActiveRecord::Base.transaction do
      pq = build_pq(form)

      form.action_officer_id.uniq.each do |id|
        action_officer = ActionOfficer.find id
        pq.action_officers << action_officer if action_officer
      end
      #     ao_pqs =
      #       form.action_officer_id.uniq.map do |ao_id|
      #         ActionOfficersPq.create!(
      #           pq_id: pq.id,
      #           action_officer_id: ao_id
      #         )
      #       end
      #     pq.action_officers_pqs << ao_pqs
      pq
    end
  end

  private

  def build_pq(form)
    pq = Pq.find(form.pq_id)
  end

  # def notify_assignment(ao_pq)
  #   ao      = ao_pq.action_officer
  #   pq      = ao_pq.pq
  #   path    = assignment_path(uin: pq.uin.encode)
  #   entity  = "assignment:#{ao_pq.id}"
  #   expires = @current_time.end_of_day + AO_TOKEN_LIFETIME.days
  #   token   = @token_service.generate_token(path, entity, expires)

  #   $statsd.increment "#{StatsHelper::TOKENS_GENERATE}.commission"

  #   LogStuff.tag(:mailer_commission) do
  #     NotifyPqMailer.commission_email(pq: pq, action_officer: ao, token: token, entity: entity, email: ao.email).deliver_later
  #     if ao.group_email.present?
  #       NotifyPqMailer.commission_email(pq: pq, action_officer: ao, token: token, entity: entity, email: ao.group_email).deliver_later
  #     end
  #   end
  # end
end
