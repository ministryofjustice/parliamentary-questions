class ProposalsController < ApplicationController

  def new
    @pq              = Pq.find params[:pq_id]
  	@action_officers = ActionOfficer.all
  end	

  def create
    @pq = Pq.find params[:pq_id]
    proposal_form = ProposalForm.new(create_params)
    if proposal_form.valid?
      pq = ProposalService.new.propose(proposal_form)
      flash[:success] = 'Action Officer was successfully updated.'
      redirect_to early_bird_dashboard_path
    else
      flash[:error] = 'Please choose a Deputy Director.'
      redirect_to new_pq_proposal_path(@pq.id)
    end  
    
  end  

end

private

def create_params
    params.require(:proposal_form).permit(:pq_id, action_officer_id: [])
end

