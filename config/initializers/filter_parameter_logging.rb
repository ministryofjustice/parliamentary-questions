# Configure parameters to be filtered from the log file. Use this to limit dissemination of

# sensitive information. See the ActiveSupport::ParameterFilter documentation for supported
# notations and behaviors.
Rails.application.config.filter_parameters += %i[
  password passw secret token _key crypt salt certificate otp ssn
]

# OAuth credentials. `code` and `state` are the two genuinely new entries:
# the broad `token` and `secret` above already match id_token, access_token,
# refresh_token and client_secret by substring. Those four are still listed
# explicitly so that narrowing `token` or `secret` later cannot silently
# unprotect them, and so a security reviewer can see the OAuth parameters
# being handled deliberately.
#
# The authorization code is the important one: it is a replayable credential
# for its lifetime, and it appears as a query parameter on every callback, so
# without this it is written to the access log on every sign-in.
#
# Note the cost of `code` and `state`: matching is by substring, so unrelated
# parameters containing them — a pq's `state`, or a `postcode` — are redacted
# in logs too. That is accepted in exchange for never logging an auth code.
Rails.application.config.filter_parameters += %i[
  code state id_token access_token refresh_token client_secret
]
