class PressOfficersController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_press_officer, only: [:show, :edit, :update, :destroy]
  before_action :prepare_press_offices

  # GET /press_officers
  # GET /press_officers.json
  def index
    @press_officers = PressOfficer.all.order('lower(name)')
  end

  # GET /press_officers/1
  # GET /press_officers/1.json
  def show
  end

  # GET /press_officers/new
  def new
    @press_officer = PressOfficer.new
  end

  # GET /press_officers/1/edit
  def edit
  end

  # POST /press_officers
  def create
    @press_officer = PressOfficer.new(press_officer_params)

      if @press_officer.save
        redirect_to @press_officer, notice: 'Press officer was successfully created.'
      else
        render action: 'new'
      end
  end

  # PATCH/PUT /press_officers/1
  def update
      if @press_officer.update(press_officer_params)
        redirect_to @press_officer, notice: 'Press officer was successfully updated.'
      else
        render action: 'edit'
      end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_press_officer
      @press_officer = PressOfficer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def press_officer_params
      params.require(:press_officer).permit(:name, :email, :press_desk_id, :deleted)
    end
    def prepare_press_offices
      @press_offices = PressDesk.where(deleted: false).all
    end
end
