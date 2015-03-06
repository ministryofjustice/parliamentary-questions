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
    loading_records(:existing) 
  end

  def new
    loading_records(:new)
  end

  def create
    loading_records(:new) do      
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
   loading_records(:existing)
  end

  def update
    loading_records(:existing) do
      if @action_officer.update(action_officer_params)
        flash[:success] = 'Action officer was successfully updated'
        redirect_to @action_officer 
      else
        flash[:error] = 'Action officer could not be updated'
        render action: 'edit'  
      end
    end
  end

  def find
    @results = ActionOfficer.by_name(params[:q]).select(:id, :name)
    render json: @results
  end

  private

  def loading_records(type)
    @deputy_directors = DeputyDirector.active
    @press_desks      = PressDesk.active
    @action_officer   =
      case type
      when :new
        ActionOfficer.new
      when :existing
        ActionOfficer.find(params[:id])
      else
        raise ArgumentError, 'the specified record type is not supported'
      end
    
    yield if block_given?
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
