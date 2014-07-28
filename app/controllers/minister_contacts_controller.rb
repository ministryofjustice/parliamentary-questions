class MinisterContactsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_minister, only: [:new, :create]

  def new
    @minister_contact = MinisterContact.new(minister_id: @minister.id, deleted: false)
  end

  def create
    @minister_contact = MinisterContact.new(minister_contacts_params)

      if @minister_contact.save
        redirect_to @minister, notice: 'Contact was successfully created.'
      else
        render action: 'new'
      end
  end

  def show
  end

  def update
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_minister
    if params[:id].nil?
      @minister = Minister.find(params[:minister_contact][:minister_id])
    else
      @minister = Minister.find(params[:id])
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def minister_contacts_params
    params.require(:minister_contact).permit(:name, :email, :phone, :deleted, :minister_id)
  end
end
