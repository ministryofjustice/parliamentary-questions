class ProposalsController < ApplicationController

  def new
    @pq              = Pq.find params[:pq_id]
  	@action_officers = ActionOfficer.all
  end	

end