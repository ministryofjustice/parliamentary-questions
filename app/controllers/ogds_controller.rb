class OgdsController < ApplicationController
  before_action :set_ogd, only: [:show, :edit, :update, :destroy]

  # GET /ogds
  # GET /ogds.json
  def index
    @ogds = Ogd.all
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
  # POST /ogds.json
  def create
    @ogd = Ogd.new(ogd_params)

    respond_to do |format|
      if @ogd.save
        format.html { redirect_to @ogd, notice: 'OGD was successfully created.' }
        format.json { render action: 'show', status: :created, location: @ogd }
      else
        format.html { render action: 'new' }
        format.json { render json: @ogd.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ogds/1
  # PATCH/PUT /ogds/1.json
  def update
    respond_to do |format|
      if @ogd.update(ogd_params)
        format.html { redirect_to @ogd, notice: 'Ogd was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @ogd.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ogds/1
  # DELETE /ogds/1.json
  def destroy
    @ogd.destroy
    respond_to do |format|
      format.html { redirect_to ogds_url }
      format.json { head :no_content }
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
