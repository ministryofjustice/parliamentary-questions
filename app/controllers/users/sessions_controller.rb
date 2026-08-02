class Users::SessionsController < Devise::SessionsController
  skip_before_action :set_paper_trail_whodunnit

  def create
    unless AuthMethods.password_enabled?
      redirect_to new_user_session_path, alert: t("devise.failure.password_sign_in_disabled") and return
    end

    csrf = session["_csrf_token"]
    reset_session
    session["_csrf_token"] = csrf
    super
  end
end
