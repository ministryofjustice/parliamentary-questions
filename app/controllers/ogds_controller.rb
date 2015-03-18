class OgdsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_ogd, only: [:show, :edit, :update, :destroy]

  def index
    @ogds = Ogd.order('lower(name)')
  end

  def new
    @ogd = Ogd.new
  end

  def create
    @ogd = Ogd.new(ogd_params)

    if @ogd.save
      flash[:success] ='OGD was successfully created.'
      redirect_to @ogd
    else
      render action: 'new'
    end
  end

  def update
    if @ogd.update(ogd_params)
      flash[:success] = 'Ogd was successfully updated.'
      redirect_to @ogd
    else
      render action: 'edit'
    end
  end

  def find
    @results = Ogd.by_name(params[:q]).select(:id, :name, :deleted)
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
