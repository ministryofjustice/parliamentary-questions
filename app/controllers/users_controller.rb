class UsersController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def index
    @users = User.order("lower(name)").page(params[:page]).per_page(15)
  end

  def edit
    @user = User.find(params[:id])
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    flash[:success] = 'User updated' if @user.update_attributes(user_params)
    redirect_to users_path
  end

  protected

  def user_params
    params.require(:user).permit(:email, :admin, :name, :roles, :deleted)
  end
end
