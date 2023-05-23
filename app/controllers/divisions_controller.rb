class DivisionsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_division, only: [:show, :edit, :update, :destroy]
  before_action :prepare_directorates

  def index
    @divisions = Division.active_list
                         .joins(:directorate)
                         .order(deleted: :asc)
                         .order(Arel.sql('lower(directorates.name)'))
                         .order(Arel.sql('lower(divisions.name)'))
    update_page_title(t('page.title.divisions'))
  end

  def show
    update_page_title(t('page.title.division_details'))
  end

  def new
    @division = Division.new
    update_page_title(t('page.title.division_add'))
  end

  def edit
    update_page_title(t('page.title.division_edit'))
  end

  def create
    @division = Division.new(division_params)

    if @division.save
      flash[:success] = t('page.flash.division_created')
      redirect_to @division
    else
      render action: 'new'
    end
  end

  def update
    if @division.update(division_params)
      flash[:succees] = t('page.flash.division_updated')
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
    @directorates = Directorate.active.order(Arel.sql('lower(name)'))
  end
end
