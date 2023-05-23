class UsersController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def index
    @users = User.active_list.order(deleted: :asc).order(Arel.sql('lower(name)'))
    update_page_title(t('page.title.users'))
  end

  def show
    @user = User.find(params[:id])
    update_page_title(t('page.title.user_details'))
  end

  def edit
    @user = User.find(params[:id])
    update_page_title(t('page.title.user_edit'))
  end

  def update
    @user = User.find(params[:id])
    flash[:success] = t('page.flash.user_updated') if @user.update(user_params)
    redirect_to users_path
  end

  protected

  def user_params
    params.require(:user).permit(:email, :name, :roles, :deleted)
  end
end
