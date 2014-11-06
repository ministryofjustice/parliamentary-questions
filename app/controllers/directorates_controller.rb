class DirectoratesController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_directorate, only: [:show, :edit, :update, :destroy]

  def index
    @directorates = Directorate.all.order('lower(name)')
  end

  def new
    @directorate = Directorate.new
  end

  def create
    @directorate = Directorate.new(directorate_params)
    if @directorate.save
      redirect_to @directorate, notice: 'Directorate was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @directorate.update(directorate_params)
      redirect_to @directorate, notice: 'Directorate was successfully updated.'
    else
      render action: 'edit'
    end
  end


private
  def set_directorate
    @directorate = Directorate.find(params[:id])
  end

  def directorate_params
    params.require(:directorate).permit(:name, :deleted)
  end
end
