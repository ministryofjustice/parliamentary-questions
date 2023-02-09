class ProposalsController < ApplicationController
  before_action :load_pq, only: [:new, :create]
  before_action :authenticate_user, only: [:new, :create]

  def new
    @action_officers = ActionOfficer.all
  end

  def create
    proposal_form = ProposalForm.new(create_params)
    if proposal_form.valid?
      pq = ProposalService.new.propose(proposal_form)
      flash[:success] = 'Successfully proposed Deputy Director(s)'
      redirect_to early_bird_landing_page_path
    else
      flash[:error] = 'Please choose a Deputy Director.'
      redirect_to new_pq_proposal_path(@pq.id)
    end
  end
end

private

def authenticate_user
  redirect_to_early_bird_dashboard unless current_user || user_has_valid_early_bird_credentials?
end

def redirect_to_early_bird_dashboard
  token = session[:early_bird_token]
  entity = session[:early_bird_entity]
  redirect_to early_bird_dashboard_path(token: token, entity: entity)
end

def user_has_valid_early_bird_credentials?
  entity = session[:early_bird_entity]
  token = session[:early_bird_token]
  token_service = TokenService.new
  path = '/early_bird/dashboard'
  if entity && token
    return token_service.valid?(token, path, entity) && !
      token_service.expired?(token, path, entity)
  end
  false
end

def load_pq
  @pq = Pq.find params[:pq_id]
end

def early_bird_landing_page_path
  token = session[:early_bird_token]
  entity = session[:early_bird_entity]
  if entity && token
    early_bird_dashboard_path(token: token, entity: entity)
  else
    early_bird_preview_path
  end
end

def create_params
  params.require(:proposal_form).permit(:pq_id, action_officer_id: [])
end
