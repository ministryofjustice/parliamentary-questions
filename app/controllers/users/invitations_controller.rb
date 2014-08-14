class Users::InvitationsController < Devise::InvitationsController
  private

  # this is called when creating invitation
  # should return an instance of resource class
  def invite_resource
    # we don't need this to override the function of inviting
    # but it is necessary to allow the use of our views
    resource_class.invite!(invite_params, current_inviter) do |u|

      puts '======================================================='
      puts ' My code, talking ''bout... MY CODE!'
      puts '======================================================='
      puts invite_params
      puts '======================================================='

    end
  end

  # this is called when accepting invitation
  # should return an instance of resource class
  def accept_resource
    puts '======================================================='
    puts ' My acceptance, talking ''bout... MY Acceptance!'
    puts '======================================================='
    puts update_resource_params
    puts '======================================================='
    resource = resource_class.accept_invitation!(update_resource_params)
    resource
  end

  def update_resource_params
    params.require(:user).permit(:password, :password_confirmation, :name, :email, :roles, :invitation_token)
  end
end