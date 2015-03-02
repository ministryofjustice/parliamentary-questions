class MinisterContactsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def new
    @minister_contact = MinisterContact.new(minister_id: params[:id])
    @minister         = @minister_contact.minister
  end

  def create
    @minister_contact = MinisterContact.new(minister_contacts_params)
    @minister         = @minister_contact.minister

    if @minister_contact.save
      redirect_to @minister, notice: 'Contact was successfully created.'
    else
      render action: 'new'
    end
  end

  def edit
    @minister_contact = MinisterContact.find(params[:id])
    @minister         = @minister_contact.minister
  end

  def update
    @minister_contact = MinisterContact.find(params[:id])
    @minister         = @minister_contact.minister

    if @minister_contact.update(minister_contacts_params)
      redirect_to @minister_contact.minister, notice: 'Contact was successfully updated.'
    else
      render action: 'edit'
    end
  end

  private

  def minister_contacts_params
    params.require(:minister_contact).permit(:name, :email, :phone, :deleted, :minister_id)
  end
end
