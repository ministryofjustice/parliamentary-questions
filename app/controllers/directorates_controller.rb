class DirectoratesController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_directorate, only: [:show, :edit, :update, :destroy]

  def index
    @directorates = Directorate.active_list.order(deleted: :asc).order(Arel.sql('lower(name)'))
    update_page_title(t('page.title.directorates'))
  end

  def show
    update_page_title(t('page.title.directorate_details'))
  end

  def new
    @directorate = Directorate.new
    update_page_title(t('page.title.directorate_add'))
  end

  def edit
    update_page_title(t('page.title.directorate_edit'))
  end

  def create
    @directorate = Directorate.new(directorate_params)
    if @directorate.save
      flash[:success] = t('page.flash.directorate_created')
      redirect_to @directorate
    else
      render action: 'new'
    end
  end

  def update
    if @directorate.update(directorate_params)
      flash[:success] = t('page.flash.directorate_updated')
      redirect_to @directorate
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
