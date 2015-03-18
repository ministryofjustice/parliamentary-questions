class ActionlistMembersController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_actionlist_member, only: [:show, :edit, :update, :destroy]

  def index
    @actionlist_members = ActionlistMember.all.order(:name.downcase)
  end

  def new
    @actionlist_member = ActionlistMember.new
  end

  def create
    @actionlist_member = ActionlistMember.new(actionlist_member_params)

    if @actionlist_member.save
      flash[:success] = 'Actionlist member was successfully created.'
      redirect_to @actionlist_member 
    else
      render action: 'new'
    end
  end

  def update
    if @actionlist_member.update(actionlist_member_params)
      flash[:success] = 'Actionlist member was successfully updated.'
      redirect_to @actionlist_member 
    else
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
