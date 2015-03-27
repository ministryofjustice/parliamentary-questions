class ActionlistMembersController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_actionlist_member, only: [:show, :edit, :update, :destroy]

  def index
    @actionlist_members = ActionlistMember.all.order(:name.downcase)
    update_page_title('Actionlist Members Index')
  end

  def new
    @actionlist_member = ActionlistMember.new
    update_page_title('Add Actionlist Member')
  end

  def show
    update_page_title('Actionlist Member Details')
  end

  def edit
    update_page_title('Edit Actionlist Member')
  end

  def create
    @actionlist_member = ActionlistMember.new(actionlist_member_params)

    if @actionlist_member.save
      flash[:success] = 'Actionlist member was successfully created.'
      update_page_title('Actionlist Member Details')
      redirect_to @actionlist_member 
    else
      render action: 'new'
    end
  end

  def update
    if @actionlist_member.update(actionlist_member_params)
      flash[:success] = 'Actionlist member was successfully updated.'
      update_page_title('Actionlist Member Details')
      redirect_to @actionlist_member 
    else
      update_page_title('Edit Actionlist Member')
      render action: 'edit'
    end
  end

private

  def set_actionlist_member
    @actionlist_member = ActionlistMember.find(params[:id])
  end

  def actionlist_member_params
    params.require(:actionlist_member).permit(:name, :email, :deleted)
  end
end
