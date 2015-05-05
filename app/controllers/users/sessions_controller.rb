class Users::SessionsController < Devise::SessionsController
  def create
    reset_session
    super
  end
end