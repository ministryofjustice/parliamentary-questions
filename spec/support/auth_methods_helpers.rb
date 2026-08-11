# Helpers for specs that exercise the AUTH_METHODS feature flag
# (see lib/auth_methods.rb). Usage:
#
#   set_auth_methods("sso_only")
#
# The flag is read from ENV on every call, so stubbing ENV per-example is
# sufficient and is automatically undone by RSpec.
module AuthMethodsHelpers
  def set_auth_methods(mode)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("AUTH_METHODS").and_return(mode)
  end
end

RSpec.configure do |config|
  config.include AuthMethodsHelpers
end
