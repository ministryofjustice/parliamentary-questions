class DeputyDirectorsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_deputy_director, only: [:show, :edit, :update, :destroy]
  before_action :prepare_divisions

  def index
    @deputy_directors = DeputyDirector.active_list
                                      .joins(:division)
                                      .order(deleted: :asc)
                                      .order(Arel.sql('lower(divisions.name)'))
                                      .order(Arel.sql('lower(deputy_directors.name)'))
    update_page_title(t('page.title.deputy_directors'))
  end

  def show
    update_page_title(t('page.title.deputy_director_details'))
  end

  def new
    @deputy_director = DeputyDirector.new
    update_page_title(t('page.title.deputy_director_add'))
  end

  def edit
    update_page_title(t('page.title.deputy_director_edit'))
  end

  def create
    @deputy_director = DeputyDirector.new(deputy_director_params)

    if @deputy_director.save
      flash[:success] = t('page.flash.deputy_director_created')
      redirect_to @deputy_director
    else
      render action: 'new'
    end
  end

  def update
    if @deputy_director.update(deputy_director_params)
      flash[:success] = t('page.flash.deputy_director_updated')
      redirect_to @deputy_director
    else
      render action: 'edit'
    end
  end

  private

  def set_deputy_director
    @deputy_director = DeputyDirector.find(params[:id])
  end

  def deputy_director_params
    params.require(:deputy_director).permit(:name, :email, :deleted, :division_id)
  end

  def prepare_divisions
    @divisions = Division.active.order(Arel.sql('lower(name)'))
  end
end
