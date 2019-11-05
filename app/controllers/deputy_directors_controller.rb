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
                                      .page(params[:page])
                                      .per_page(15)
    update_page_title 'Deputy directors'
  end

  def new
    @deputy_director = DeputyDirector.new
    update_page_title 'Add deputy director'
  end

  def show
    update_page_title('Deputy director details')
  end

  def edit
    update_page_title('Edit deputy director')
  end

  def create
    @deputy_director = DeputyDirector.new(deputy_director_params)

    if @deputy_director.save
      flash[:success] = 'Deputy director was successfully created.'
      redirect_to @deputy_director
    else
      render action: 'new'
    end
  end

  def update
    if @deputy_director.update(deputy_director_params)
      flash[:success] = 'Deputy director was successfully updated.'
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
