module Users
  # Where Entra hands the user back. By the time an action here runs, the
  # `state` parameter has already been verified by omniauth-oauth2 middleware,
  # so it is deliberately not re-checked and the session is left untouched
  # until the identity is settled.
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # There is no current_user yet, so there is nobody to attribute versions
    # to. Carried across from Users::SessionsController.
    skip_before_action :set_paper_trail_whodunnit

    def entra_id
      claims = AzureOauth::Claims.new(request.env["omniauth.auth"])

      return refuse(claims.error) unless claims.valid?

      sign_in_resolved(claims)
    rescue AzureOauth::UserResolver::IdentityConflict => e
      refuse(:identity_conflict, e.message)
    end

    # The development strategy runs the real code path rather than a parallel
    # one, so exercising sign-in locally exercises claim validation,
    # resolution and session rotation exactly as a deployed environment does.
    alias_method :developer, :entra_id

    # Handles OmniAuth's own failures: invalid_credentials, csrf_detected,
    # timeouts, and access_denied when someone clicks Cancel at the Microsoft
    # prompt.
    #
    # Overridden rather than inherited because Devise's version builds a flash
    # from `failed_strategy.name` and `failure_message`. On access_denied there
    # is no exception object and `omniauth.error.strategy` may be unset, so
    # `failed_strategy.name` raises NoMethodError and turns a routine
    # cancellation into a 500. It would also render provider-supplied text into
    # a PQ page, which the design rules out.
    def failure
      LogStuff.warn(:oauth) do
        "OmniAuth request failed: #{failure_type} (strategy: #{failed_strategy_name})"
      end

      redirect_to sign_in_failed_path
    end

  private

    def sign_in_resolved(claims)
      user = AzureOauth::UserResolver.new(claims).call

      # Captured BEFORE reset_session, because stored_location_for reads the
      # session — reading it afterwards would silently discard the deep link
      # that sent the user into the OAuth journey in the first place.
      destination = stored_location_for(:user) || root_path

      reset_session
      sign_in(user, event: :authentication)

      redirect_to destination
    end

    # Reasons are logged and never rendered: the page says only that sign-in
    # could not be completed. Naming the failed check would tell an attacker
    # which claim to forge, and echoing provider text is a reflected-content
    # vector.
    def refuse(reason, detail = nil)
      LogStuff.warn(:oauth) do
        ["Refused sign in: #{reason}", claim_oid, detail].compact.join(" | ")
      end

      redirect_to sign_in_failed_path
    end

    # Best-effort, for the log line only. The oid is absent precisely in the
    # :missing_oid case, so this must not raise.
    def claim_oid
      oid = request.env.dig("omniauth.auth", "uid")
      "oid: #{oid}" if oid.present?
    rescue StandardError
      nil
    end

    def failure_type
      request.env["omniauth.error.type"].presence || "unknown"
    end

    def failed_strategy_name
      failed_strategy&.name || "unknown"
    end
  end
end
