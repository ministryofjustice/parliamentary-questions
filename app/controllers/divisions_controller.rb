class DivisionsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_division, only: [:show, :edit, :update, :destroy]
  before_action :prepare_directorates

  def index
    @divisions = Division.all.joins(:directorate).order('lower(directorates.name)').order('lower(divisions.name)')
  end

  def new
    @division = Division.new
  end

  def create
    @division = Division.new(division_params)

    if @division.save
      redirect_to @division, notice: 'Division was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @division.update(division_params)
      flash[:success] = 'Division successfully updated'
      redirect_to @division
    else
      render action: 'edit'
    end
  end

private

  def set_division
    @division = Division.find(params[:id])
  end

  def division_params
    params.require(:division).permit(:name, :deleted, :directorate_id)
  end
  def prepare_directorates
    @directorates = Directorate.where(deleted: false).order('lower(name)')
  end
end
