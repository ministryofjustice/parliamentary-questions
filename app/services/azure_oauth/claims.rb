module AzureOauth
  # Reads and validates the claims on an OmniAuth auth hash.
  #
  # Where the claims actually sit, verified against the installed
  # omniauth-entra-id 3.1.1 strategy source rather than assumed:
  #
  #   auth["uid"]             the bare `oid`, because config/initializers/devise.rb
  #                           registers the strategy with `ignore_tid: true`.
  #                           Left at its default the gem returns `tid + oid`
  #                           concatenated, which would not match users.azure_oid.
  #   auth["info"]["name"]    raw_info["name"]
  #   auth["info"]["email"]   raw_info["email"] ONLY — the gem performs no
  #                           fallback, so the fallback chain here reads
  #                           raw_info directly instead of trusting info.
  #   auth["extra"]["raw_info"]
  #                           the merged id_token and access_token claims:
  #                           oid, tid, aud, iss, email, upn,
  #                           preferred_username, name.
  #
  # The gem does NOT verify the id_token signature — both decodes are
  # `JWT.decode(token, nil, false)` — and relies on having received the token
  # over TLS straight from the token endpoint.
  #
  # It DOES verify aud, iss, exp and nbf, via JWT::Claims.verify_payload!
  # against the id_token, immediately BEFORE merging the access token's claims
  # over it. So those four are already enforced on the correct token, and the
  # values left in the merged raw_info below are not necessarily the id_token's
  # — which is why this class checks only `tid`. See #entra_error.
  #
  # #error is for logging only and is never rendered: provider-supplied text
  # reaching a PQ-branded page is a reflected-content vector.
  class Claims
    DEVELOPER_PROVIDER   = "developer".freeze
    DEVELOPER_OID_PREFIX = "dev-".freeze

    # In claim-preference order. Entra populates these inconsistently between
    # tenants and account types, so all three are tried.
    EMAIL_CLAIMS = %w[email preferred_username upn].freeze

    def initialize(auth_hash)
      @auth = auth_hash || {}
    end

    def valid?
      error.nil?
    end

    # The first failed check, or nil. Memoised through `defined?` rather than
    # `||=` so that a valid hash is not re-validated on every call.
    def error
      return @error if defined?(@error)

      @error = developer? ? developer_error : entra_error
    end

    # Downcased and stripped: Entra sends a lowercase GUID, and normalising on
    # the way in means a variant spelling can never produce a second row for
    # the same human.
    def oid
      return if raw_oid.blank?

      developer? ? "#{DEVELOPER_OID_PREFIX}#{raw_oid.downcase}" : raw_oid.downcase
    end

    # Stripped but deliberately not downcased. Task 5 matches existing rows
    # case-insensitively, and this value is also written back to the user as a
    # display and notification field, so the tenant's casing is preserved.
    def email
      EMAIL_CLAIMS.filter_map { |claim| presence(raw_info[claim]) }.first ||
        presence(info["email"])
    end

    def name
      presence(raw_info["name"]) || presence(info["name"])
    end

  private

    attr_reader :auth

    def developer?
      provider == DEVELOPER_PROVIDER
    end

    def provider
      auth["provider"].to_s
    end

    # The developer strategy carries no tenant claims at all — it has no
    # raw_info — so a present uid is the only thing there is to check. It is
    # registered in development only; see the guard in the Devise initializer.
    def developer_error
      :missing_oid if raw_oid.blank?
    end

    # Only `tid` is checked here, deliberately.
    #
    # The gem validates `aud`, `iss`, `exp` and `nbf` itself, via
    # JWT::Claims.verify_payload! against the id_token — and crucially it does
    # so BEFORE `id_token_data.merge!(auth_token_data)` overwrites those keys
    # with the ACCESS token's values. The merged raw_info visible here can
    # therefore carry Graph's app id as `aud` and the v1 `sts.windows.net`
    # issuer, for any account type whose access token happens to decode. A
    # re-check here would refuse every legitimate sign-in — in some tenants and
    # not others, depending on whether that decode succeeds.
    #
    # `tid` is the opposite case and is why this method still exists: it is
    # identical in both tokens, the gem never verifies it, and tenant
    # membership is this service's only access gate. This is the only tid check
    # in the system.
    def entra_error
      return :tenant_mismatch unless claim_matches?(raw_info["tid"], Settings.omniauth_azure_tenant_id)
      return :missing_oid if raw_oid.blank?

      nil
    end

    # A blank expected value never matches. An unconfigured tenant must
    # authenticate nobody rather than everybody — tenant membership is the only
    # access gate, so this fails closed by design.
    def claim_matches?(actual, expected)
      return false if actual.blank? || expected.blank?

      ActiveSupport::SecurityUtils.secure_compare(actual.to_s, expected.to_s)
    end

    def raw_oid
      @raw_oid ||= presence(raw_info["oid"]) || presence(auth["uid"])
    end

    def raw_info
      @raw_info ||= auth.dig("extra", "raw_info") || {}
    end

    def info
      @info ||= auth["info"] || {}
    end

    def presence(value)
      value.to_s.strip.presence
    end
  end
end
