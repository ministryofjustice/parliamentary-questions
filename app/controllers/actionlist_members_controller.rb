class ActionlistMembersController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_actionlist_member, only: [:show, :edit, :update, :destroy]

  def index
    @actionlist_members = ActionlistMember.all.order(:name.downcase)
    update_page_title('Actionlist members')
  end

  def new
    @actionlist_member = ActionlistMember.new
    update_page_title('Add actionlist nember')
  end

  def show
    update_page_title('Actionlist member details')
  end

  def edit
    update_page_title('Edit actionlist member')
  end

  def create
    @actionlist_member = ActionlistMember.new(actionlist_member_params)

    if @actionlist_member.save
      flash[:success] = 'Actionlist member was successfully created.'
      update_page_title('Actionlist member details')
      redirect_to @actionlist_member
    else
      render action: 'new'
    end
  end

  def update
    if @actionlist_member.update(actionlist_member_params)
      flash[:success] = 'Actionlist member was successfully updated.'
      update_page_title('Actionlist member details')
      redirect_to @actionlist_member
    else
      update_page_title('Edit actionlist member')
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
