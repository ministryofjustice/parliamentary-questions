class DivisionsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_division, only: [:show, :edit, :update, :destroy]
  before_action :prepare_directorates

  def index
    @divisions = Division.joins(:directorate).order('lower(directorates.name)').order('lower(divisions.name)')
    update_page_title('Divisions Index')
  end

  def new
    @division = Division.new
    update_page_title('New Division')
  end

  def show
    update_page_title('Division Details')
  end

  def edit
    update_page_title('Edit Division')
  end

  def create
    @division = Division.new(division_params)

    if @division.save
      flash[:success] = 'Division was successfully created.'
      redirect_to @division
    else
      render action: 'new'
    end
  end

  def update
    if @division.update(division_params)
      flash[:succees] = 'Division successfully updated'
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
    @directorates = Directorate.active.order('lower(name)')
  end
end
