class Users::SessionsController < Devise::SessionsController
  def create
    csrf = session['_csrf_token']
    reset_session
    session['_csrf_token'] = csrf
    super
  end
end