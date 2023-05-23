class ActionlistMembersController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_actionlist_member, only: [:show, :edit, :update, :destroy]

  def index
    @actionlist_members = ActionlistMember.active_list.all.order(:name.downcase)
    update_page_title(t('page.title.actionlist_members'))
  end

  def show
    update_page_title(t('page.title.actionlist_member_details'))
  end

  def new
    @actionlist_member = ActionlistMember.new
    update_page_title(t('page.title.actionlist_member_add'))
  end

  def edit
    update_page_title(t('page.title.actionlist_member_edit'))
  end

  def create
    @actionlist_member = ActionlistMember.new(actionlist_member_params)

    if @actionlist_member.save
      flash[:success] = t('page.flash.actionlist_member_created')
      update_page_title(t('page.title.actionlist_member_details'))
      redirect_to @actionlist_member
    else
      render action: 'new'
    end
  end

  def update
    if @actionlist_member.update(actionlist_member_params)
      flash[:success] = t('page.flash.actionlist_member_created')
      update_page_title(t('page.title._details'))
      redirect_to @actionlist_member
    else
      update_page_title(t('page.title.actionlist_member_edit'))
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
