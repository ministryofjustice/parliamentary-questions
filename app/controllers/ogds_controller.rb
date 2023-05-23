class OgdsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_ogd, only: [:show, :edit, :update, :destroy]

  def index
    @ogds = Ogd.active_list.order('lower(name)')
    update_page_title(t('page.title.government_departments'))
  end

  def show
    update_page_title(t('page.title.government_department_details'))
  end

  def new
    @ogd = Ogd.new
    update_page_title(t('page.title.government_department_add'))
  end

  def edit
    update_page_title(t('page.title.government_department_edit'))
  end

  def create
    @ogd = Ogd.new(ogd_params)

    if @ogd.save
      flash[:success] = t('page.flash.government_department_created')
      redirect_to @ogd
    else
      render action: 'new'
    end
  end

  def update
    if @ogd.update(ogd_params)
      flash[:success] = t('page.flash.government_department_updated')
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
