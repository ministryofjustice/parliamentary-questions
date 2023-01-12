class ProposalsController < ApplicationController

  def new
    @pq              = Pq.find params[:pq_id]
  	@action_officers = ActionOfficer.all
  end	

  def create
    byebug
    action_officers_ids = params[:proposal_form][:action_officer_id]
    pq                  = Pq.find params[:pq_id]
    action_officers_ids = action_officers_ids.reject {|item| item.blank? }
    action_officers_ids.each do |id|
      action_officer = ActionOfficer.find id
      pq.action_officers << action_officer if action_officer
    end
    flash[:success] = 'Action Officer was successfully updated.'
    redirect_to early_bird_dashboard_path
  end  

end

private

def new_params
    params.require(:proposal_form)
          .permit(:pq_id)
end

def create_params
    params.require(:proposal_form)
          .permit(:pq_id,
                  { action_officer_id: [] })
end

