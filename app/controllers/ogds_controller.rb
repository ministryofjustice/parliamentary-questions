class OgdsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_ogd, only: [:show, :edit, :update, :destroy]

  # GET /ogds
  # GET /ogds.json
  def index
    @ogds = Ogd.all.order('lower(name)')
  end

  # GET /ogds/1
  # GET /ogds/1.json
  def show
  end

  # GET /ogds/new
  def new
    @ogd = Ogd.new
  end

  # GET /ogds/1/edit
  def edit
  end

  # POST /ogds
  def create
    @ogd = Ogd.new(ogd_params)

      if @ogd.save
        redirect_to @ogd, notice: 'OGD was successfully created.'
      else
        render action: 'new'
      end
  end

  # PATCH/PUT /ogds/1
  def update
      if @ogd.update(ogd_params)
        redirect_to @ogd, notice: 'Ogd was successfully updated.'
      else
        render action: 'edit'
      end
  end

  def find
    @results = Ogd.where("name ILIKE :search OR acronym ILIKE :search", search: "%#{params[:q]}%").select(:id, :name, :deleted)
    puts '++++++++++++++++++'
  puts @results
    puts '++++++++++++++++++'
    render json: @results
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ogd
      @ogd = Ogd.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ogd_params
      params.require(:ogd).permit(:name, :acronym, :deleted)
    end
end
