class UsersController < ApplicationController
  before_action :authenticate_user!, PqUserFilter

  def index
    @users = User.active_list
                 .order(deleted: :asc)
                 .order(Arel.sql("lower(name)"))
    update_page_title("Users")
  end

  def edit
    @user = User.find(params[:id])
    update_page_title("Edit user")
  end

  def show
    @user = User.find(params[:id])
    update_page_title("User details")
  end

  def update
    @user = User.find(params[:id])
    flash[:success] = "User updated" if @user.update(user_params)
    redirect_to users_path
  end

protected

  def user_params
    params.require(:user).permit(:email, :name, :roles, :deleted)
  end
end
