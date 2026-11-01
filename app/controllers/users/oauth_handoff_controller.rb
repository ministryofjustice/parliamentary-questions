module Users
  # The page that hands a user over to Entra ID.
  #
  # This exists as an interstitial rather than a redirect because
  # omniauth-rails_csrf_protection requires the OmniAuth request phase to be a
  # POST carrying a valid authenticity token — the fix for CVE-2015-9284. A
  # plain `redirect_to "/users/auth/entra_id"` is rejected, so "automatic"
  # means a PQ page that immediately submits a POST form, with a visible button
  # as the no-JS and assistive-technology fallback.
  #
  # Task 9 re-points the `new_user_session` route name at this action, which is
  # what makes Devise's existing authenticate_user! failure path lead here
  # without touching any other controller.
  class OauthHandoffController < ApplicationController
    before_action :redirect_signed_in_user

    def new
      @mode = mode
      @provider = handoff_provider
    end

  private

    # Which strategy the form posts to.
    #
    # A developer's laptop has no Azure credentials, and posting to :entra_id
    # there makes the gem raise ArgumentError, so the developer lands on the
    # failure page with no way in. The developer strategy is registered in
    # development only (see the guard in the Devise initializer), so prefer it
    # exactly when it exists and there is no secret to do the real round trip
    # with. A developer who sets the three variables gets the real provider,
    # which is what the spec intends.
    def handoff_provider
      return :developer if developer_strategy_available?

      :entra_id
    end

    def developer_strategy_available?
      User.omniauth_providers.include?(:developer) &&
        Settings.omniauth_azure_client_secret.blank?
    end

    # An auto-submitting page reachable by a signed-in user is a loop.
    def redirect_signed_in_user
      redirect_to root_path if user_signed_in?
    end

    # Only a fresh arrival auto-submits. After an explicit sign-out or a
    # session timeout the user waits for a click, because the Entra session
    # outlives the PQ one — auto-submitting would hand them straight back in
    # and make both sign-out and config.timeout_in unobservable.
    def mode
      return :expired if flash[:timedout].present?
      return :signed_out if params[:signed_out].present?

      :fresh
    end
  end
end
