class Users::InvitationsController < Devise::InvitationsController
  private

  # this is called when creating invitation
  # should return an instance of resource class
  def invite_resource
    ## skip sending emails on invite
    resource_class.invite!(invite_params, current_inviter) do |u|
      puts '======================================================='
      puts ' My code, talking ''bout... MY CODE!'
      puts '======================================================='
      puts invite_params
      puts '======================================================='

    end
  end
end