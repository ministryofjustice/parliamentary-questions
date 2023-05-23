class MinistersController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_minister, only: [:show, :edit, :update, :destroy]

  def index
    @ministers = Minister.active_list
                         .order(deleted: :asc)
                         .order(Arel.sql('lower(name)'))
                         .page(params[:page])
                         .per_page(15)
    update_page_title(t('page.title.ministers'))
  end

  def show
    @minister_contacts = @minister.minister_contacts
    update_page_title(t('page.title.minister_details'))
  end

  def new
    @minister = Minister.new
    @minister.minister_contacts << MinisterContact.new
    update_page_title(t('page.title.minister_add'))
  end

  def edit
    update_page_title(t('page.title.minister_edit'))
  end

  def create
    @minister = Minister.new(minister_params)
    if @minister.save
      flash[:success] = t('page.flash.minister_created')
      redirect_to @minister
    else
      render action: 'new'
    end
  end

  def update
    if @minister.update(minister_params)
      flash[:success] = t('page.flash.minister_updated')
      redirect_to @minister
    else
      render action: 'edit'
    end
  end

  private

  def set_minister
    @minister = Minister.find(params[:id])
  end

  def minister_params
    params.require(:minister).permit(:name, :title, :email, :deleted, :member_id, minister_contacts_attributes: [:id, :name, :email, :phone, :deleted, :minister_id])
  end
end
