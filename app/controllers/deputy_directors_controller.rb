class DeputyDirectorsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_deputy_director, only: [:show, :edit, :update, :destroy]
  before_action :prepare_divisions

  def index
    @deputy_directors = DeputyDirector.all.joins(:division).order('lower(divisions.name)').order('lower(deputy_directors.name)')
  end

  def new
    @deputy_director = DeputyDirector.new
  end

  def create
    @deputy_director = DeputyDirector.new(deputy_director_params)

      if @deputy_director.save
        redirect_to @deputy_director, notice: 'Deputy director was successfully created.'
      else
        render action: 'new'
      end
  end

  def update
    if @deputy_director.update(deputy_director_params)
      redirect_to @deputy_director, notice: 'Deputy director was successfully updated.'
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
    @divisions = Division.where(deleted: false).order('lower(name)')
  end
end
