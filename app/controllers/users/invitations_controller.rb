class Users::InvitationsController < Devise::InvitationsController
private

  def invite_resource
    resource_class.invite!(invite_params, current_inviter) do |u|
      LogStuff.info "Sending invite #{invite_params.inspect}"
    end
  end

  def accept_resource
    resource = resource_class.accept_invitation!(update_resource_params)
    resource
  end

  def invite_params
    params.require(:user).permit(:name, :email, :roles, :deleted)
  end

  def update_resource_params
    params.require(:user).permit(:password, :password_confirmation, :name, :email, :roles, :invitation_token)
  end
end
