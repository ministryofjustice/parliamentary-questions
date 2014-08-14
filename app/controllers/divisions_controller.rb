class DivisionsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_division, only: [:show, :edit, :update, :destroy]
  before_action :prepare_directorates

  # GET /divisions
  # GET /divisions.json
  def index
    @divisions = Division.all.order('lower(name)')
  end

  # GET /divisions/1
  # GET /divisions/1.json
  def show
  end

  # GET /divisions/new
  def new
    @division = Division.new
  end

  # GET /divisions/1/edit
  def edit
  end

  # POST /divisions
  def create
    @division = Division.new(division_params)

      if @division.save
        redirect_to @division, notice: 'Division was successfully created.'
      else
        render action: 'new'
      end
  end

  # PATCH/PUT /divisions/1
  def update
      if @division.update(division_params)
        redirect_to @division, notice: 'Division was successfully updated.'
      else
        render action: 'edit'
      end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_division
      @division = Division.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def division_params
      params.require(:division).permit(:name, :deleted, :directorate_id)
    end
    def prepare_directorates
      @directorates = Directorate.where(deleted: false).all
    end
end
