class ActionOfficersController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def index
    @action_officers = 
      ActionOfficer.all
        .joins(:deputy_director => :division)
        .order('lower(divisions.name)')
        .order('lower(action_officers.name)')
  end

  def show
    loading_existing_records
  end

  def new
    loading_new_records
  end

  def create
    loading_new_records do      
      if @action_officer.update(action_officer_params)
        flash[:success] = 'Action officer was successfully created'
        redirect_to action_officers_path
      else
        flash[:error] = 'Action officer could not be created'
        render action: 'new'
      end
    end
  end

  def edit
   loading_existing_records
  end

  def update
    loading_existing_records do
      if @action_officer.update(action_officer_params)
        flash[:success] = 'Action officer was successfully updated'
        redirect_to action_officer_path(@action_officer)
      else
        flash[:error] = 'Action officer could not be updated'
        render action: 'edit'  
      end
    end
  end

  def find
    render json: ActionOfficer.by_name(params[:q]).select(:id, :name)
  end

  private

  def loading_new_records
    loading_defaults
    @action_officer = ActionOfficer.new
    yield if block_given?
  end

  def loading_existing_records
    loading_defaults
    @action_officer = ActionOfficer.find(params[:id])
    yield if block_given?
  end

  def loading_defaults
    @deputy_directors = DeputyDirector.active
    @press_desks      = PressDesk.active
  end

  def action_officer_params
    params
      .require(:action_officer)
      .permit(
        :name, 
        :email, 
        :group_email, 
        :phone, 
        :deleted, 
        :deputy_director_id,
        :press_desk_id
      )
  end
end
