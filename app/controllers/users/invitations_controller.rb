class Users::InvitationsController < Devise::InvitationsController
  private

  # this is called when creating invitation
  # should return an instance of resource class
  def invite_resource
    # we don't need this to override the function of inviting
    # but it is necessary to allow the use of our views
    resource_class.invite!(invite_params, current_inviter) do |u|
      Rails.logger.info "Sending invite #{invite_params.inspect}"
    end
  end

  # this is called when accepting invitation
  # should return an instance of resource class
  def accept_resource
    resource = resource_class.accept_invitation!(update_resource_params)
    resource
  end
  def invite_params
    params.require(:user).permit(:name, :email, :roles, :is_active)
  end
  def update_resource_params
    params.require(:user).permit(:password, :password_confirmation, :name, :email, :roles, :invitation_token)
  end
end