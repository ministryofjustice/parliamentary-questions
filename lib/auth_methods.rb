# Feature flag controlling which authentication methods are available.
#
# Set the AUTH_METHODS environment variable to one of:
#
#   both          - Azure Entra ID single sign-on AND email/password (default)
#   sso_only      - Azure Entra ID single sign-on only
#   password_only - email/password only
#
# Any other value (or no value) falls back to "both".
module AuthMethods
  BOTH          = "both".freeze
  SSO_ONLY      = "sso_only".freeze
  PASSWORD_ONLY = "password_only".freeze

  MODES = [BOTH, SSO_ONLY, PASSWORD_ONLY].freeze

module_function

  def mode
    value = ENV["AUTH_METHODS"].to_s.strip.downcase
    MODES.include?(value) ? value : BOTH
  end

  def sso_enabled?
    mode != PASSWORD_ONLY
  end

  def password_enabled?
    mode != SSO_ONLY
  end
end
