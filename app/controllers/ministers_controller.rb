class MinistersController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_minister, only: [:show, :edit, :update, :destroy]

  def index
    @ministers = Minister.order('lower(name)')
  end

  def show
    @minister_contacts = @minister.minister_contacts.active
  end

  def new
    @minister = Minister.new
    @minister.minister_contacts << MinisterContact.new
  end

  def create
    @minister = Minister.new(minister_params)
    if @minister.save
      flash[:success] = 'Minister was successfully created.'
      redirect_to @minister
    else
      render action: 'new'
    end
  end

  def update
    if @minister.update(minister_params)
      flash[:success] = 'Minister was successfully updated.'
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
    params.require(:minister).permit(:name, :title, :email, :deleted, :member_id, minister_contacts_attributes: [ :id, :name, :email, :phone, :deleted, :minister_id ])
  end
end
