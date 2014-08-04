class ActionOfficersController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_action_officer, only: [:show, :edit, :update, :destroy]
  before_action :prepare_dropdowns


  # GET /action_officers
  # GET /action_officers.json
  def index
    @action_officers = ActionOfficer.all.order(:name)
  end

  # GET /action_officers/1
  # GET /action_officers/1.json
  def show
  end

  # GET /action_officers/new
  def new
    @action_officer = ActionOfficer.new
  end

  def find
    @results = ActionOfficer.where("name ILIKE :search", search: "%#{params[:q]}%").select(:id, :name)
    render json: @results
  end
  
  # GET /action_officers/1/edit
  def edit
  end

  # POST /action_officers
  def create
    @action_officer = ActionOfficer.new(action_officer_params)
    @action_officer[:deleted] = false
    if @action_officer.save
      redirect_to @action_officer, notice: 'Action officer was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /action_officers/1
  def update
    if @action_officer.update(action_officer_params)
      redirect_to @action_officer, notice: 'Action officer was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /action_officers/1
  def destroy
    @action_officer.destroy
    redirect_to action_officers_url
  end

private
    def set_action_officer
      @action_officer = ActionOfficer.find(params[:id])
    end
    def action_officer_params
      params.require(:action_officer).permit(:name, :email, :group_email, :phone, :deleted, :deputy_director_id, :press_desk_id)
    end
    def prepare_dropdowns
      @deputy_directors = DeputyDirector.where(deleted: false).all
      @press_desks = PressDesk.where(deleted: false).all
    end
end
