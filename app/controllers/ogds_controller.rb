class OgdsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_ogd, only: [:show, :edit, :update, :destroy]

  def index
    @ogds = Ogd.all.order('lower(name)')
  end

  def new
    @ogd = Ogd.new
  end

  def create
    @ogd = Ogd.new(ogd_params)

    if @ogd.save
      redirect_to @ogd, notice: 'OGD was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @ogd.update(ogd_params)
      redirect_to @ogd, notice: 'Ogd was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def find
    @results = Ogd.where("name ILIKE :search OR acronym ILIKE :search", search: "%#{params[:q]}%").select(:id, :name, :deleted)
    render json: @results
  end

private

  def set_ogd
    @ogd = Ogd.find(params[:id])
  end

  def ogd_params
    params.require(:ogd).permit(:name, :acronym, :deleted)
  end
end
