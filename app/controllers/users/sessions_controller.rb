class Users::SessionsController < Devise::SessionsController
  skip_before_filter :set_paper_trail_whodunnit
  def create
    csrf = session['_csrf_token']
    reset_session
    session['_csrf_token'] = csrf
    super
  end
end
