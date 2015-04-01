class DeputyDirectorsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_deputy_director, only: [:show, :edit, :update, :destroy]
  before_action :prepare_divisions

  def index
    @deputy_directors = DeputyDirector.joins(:division).order('lower(divisions.name)').order('lower(deputy_directors.name)')
    update_page_title 'Deputy Directors Index'
  end

  def new
    @deputy_director = DeputyDirector.new
    update_page_title 'Add Deputy Director'
  end

  def show
    update_page_title('Deputy Director Details')
  end

  def edit
    update_page_title('Edit Deputy Director')
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
    @divisions = Division.active.order('lower(name)')
  end
end
