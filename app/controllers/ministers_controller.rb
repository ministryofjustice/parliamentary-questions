class MinistersController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_minister, only: [:show, :edit, :update, :destroy]

  # GET /ministers
  # GET /ministers.json
  def index
    @ministers = Minister.all.order('lower(name)')
  end

  # GET /ministers/1
  # GET /ministers/1.json
  def show
  end

  # GET /ministers/new
  def new
    @minister = Minister.new
    @minister.minister_contacts << MinisterContact.new
  end

  # GET /ministers/1/edit
  def edit
  end

  # POST /ministers
  def create
    @minister = Minister.new(minister_params)
      if @minister.save
        redirect_to @minister, notice: 'Minister was successfully created.'
      else
        render action: 'new'
      end
  end

  # PATCH/PUT /ministers/1
  def update
      if @minister.update(minister_params)
        redirect_to @minister, notice: 'Minister was successfully updated.'
      else
        render action: 'edit'
      end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_minister
      @minister = Minister.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def minister_params
      params.require(:minister).permit(:name, :title, :email, :deleted, :member_id, minister_contacts_attributes: [ :id, :name, :email, :phone, :deleted, :minister_id ])
    end
end
