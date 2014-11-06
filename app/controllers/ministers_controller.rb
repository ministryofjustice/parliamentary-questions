class MinistersController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_minister, only: [:show, :edit, :update, :destroy]

  def index
    @ministers = Minister.all.order('lower(name)')
  end

  def new
    @minister = Minister.new
    @minister.minister_contacts << MinisterContact.new
  end

  def create
    @minister = Minister.new(minister_params)
    if @minister.save
      redirect_to @minister, notice: 'Minister was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @minister.update(minister_params)
      redirect_to @minister, notice: 'Minister was successfully updated.'
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
