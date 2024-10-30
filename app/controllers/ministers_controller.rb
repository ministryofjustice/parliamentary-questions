class MinistersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_minister, only: %i[show edit update destroy]

  def index
    @ministers = Minister.active_list
                         .order(deleted: :asc)
                         .order(Arel.sql("lower(name)"))
                         .page(params[:page])
                         .per_page(15)
    update_page_title("Ministers")
  end

  def show
    @minister_contacts = @minister.minister_contacts
    update_page_title("Minister details")
  end

  def new
    @minister = Minister.new
    @minister.minister_contacts << MinisterContact.new
    update_page_title("Add minister")
  end

  def edit
    update_page_title("Edit minister")
  end

  def create
    @minister = Minister.new(minister_params)
    if @minister.save
      flash[:success] = "Minister was successfully created."
      redirect_to @minister
    else
      render action: "new"
    end
  end

  def update
    if @minister.update(minister_params)
      flash[:success] = "Minister was successfully updated."
      redirect_to @minister
    else
      render action: "edit"
    end
  end

  def destroy
    # This method is not implemented as we 'soft' delete data.
  end

private

  def set_minister
    @minister = Minister.find(params[:id])
  end

  def minister_params
    params.require(:minister).permit(:name, :title, :email, :deleted, :member_id, minister_contacts_attributes: %i[id name email phone deleted minister_id])
  end
end
