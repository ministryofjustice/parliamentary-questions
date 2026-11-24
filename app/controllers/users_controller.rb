class UsersController < ApplicationController
  # Admins only, not merely signed-in users. user_params below permits :roles
  # and :deleted, and the role select in the edit view offers only PQUSER — so
  # the interface hid self-escalation rather than preventing it, and a crafted
  # PATCH set roles to "PQUSER,ADMIN". That was reachable only with an emailed
  # invitation before; with Entra auto-provisioning, anyone holding an account
  # in the MoJ tenant can sign in and reach it.
  before_action :authenticate_admin!

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
