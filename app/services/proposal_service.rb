class ProposalService
  # include Rails.application.routes.url_helpers
  # AO_TOKEN_LIFETIME = 3

  # def initialize(token_service = nil, current_time = nil)
  #   @token_service = token_service || TokenService.new
  #   @current_time = current_time || DateTime.now.utc
  # end

  def propose(form)
    raise ArgumentError, "form is invalid" unless form.valid?

    ActiveRecord::Base.transaction do
      pq = build_pq(form)
      pq.action_officers << form.action_officers
      pq
    end
  end

private

  def build_pq(form)
    pq = Pq.find(form.pq_id)
  end
end
