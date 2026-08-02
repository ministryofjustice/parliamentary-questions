class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :set_paper_trail_whodunnit

  def entra_id
    unless AuthMethods.sso_enabled?
      set_flash_message(:alert, :sso_disabled) if is_flashing_format?
      redirect_to new_user_session_path and return
    end

    user = User.from_omniauth(auth)

    if user.nil? || user.deleted?
      set_flash_message(:alert, :not_found) if is_flashing_format?
      redirect_to new_user_session_path
    else
      protect_against_session_fixation
      sign_in_and_redirect user, event: :authentication
    end
  rescue ActiveRecord::RecordInvalid
    set_flash_message(:alert, :not_found) if is_flashing_format?
    redirect_to new_user_session_path
  end

private

  def auth
    request.env["omniauth.auth"]
  end

  # Mirrors the session-fixation defence in Users::SessionsController#create:
  # rotate the session on privilege change, preserving the CSRF token.
  def protect_against_session_fixation
    csrf = session["_csrf_token"]
    reset_session
    session["_csrf_token"] = csrf
  end
end
