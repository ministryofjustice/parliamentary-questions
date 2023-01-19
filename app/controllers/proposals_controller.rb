class ProposalsController < ApplicationController
  before_action :load_pq, only: [:new, :create]

  def new
  	@action_officers = ActionOfficer.all
  end	

  def create
    proposal_form = ProposalForm.new(create_params)
    if proposal_form.valid?
      pq = ProposalService.new.propose(proposal_form)
      flash[:success] = 'Successfully proposed Deputy Director(s)'
      redirect_to early_bird_dashboard_path
    else
      flash[:error] = 'Please choose a Deputy Director.'
      redirect_to new_pq_proposal_path(@pq.id)
    end  
    
  end  

end

private

def load_pq
  @pq = Pq.find params[:pq_id]
end

def create_params
    params.require(:proposal_form).permit(:pq_id, action_officer_id: [])
end

