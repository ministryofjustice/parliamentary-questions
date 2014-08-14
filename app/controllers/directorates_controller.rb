class DirectoratesController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_directorate, only: [:show, :edit, :update, :destroy]

  # GET /directorates
  # GET /directorates.json
  def index
    @directorates = Directorate.all.order('lower(name)')
  end

  # GET /directorates/1
  # GET /directorates/1.json
  def show
  end

  # GET /directorates/new
  def new
    @directorate = Directorate.new
  end

  # GET /directorates/1/edit
  def edit
  end

  # POST /directorates
  def create
      @directorate = Directorate.new(directorate_params)
      if @directorate.save
        redirect_to @directorate, notice: 'Directorate was successfully created.'
      else
        render action: 'new'
      end
  end

  # PATCH/PUT /directorates/1
  def update
      if @directorate.update(directorate_params)
        redirect_to @directorate, notice: 'Directorate was successfully updated.'
      else
        render action: 'edit'
      end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_directorate
      @directorate = Directorate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def directorate_params
      params.require(:directorate).permit(:name, :deleted)
    end
end
