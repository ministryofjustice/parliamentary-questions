require "rails_helper"

# The interstitial in Users::OauthHandoffController exists only because the
# OmniAuth request phase must be a POST carrying a valid authenticity token —
# the fix for CVE-2015-9284. A silent regression here (the gem dropped from the
# Gemfile, or allowed_request_methods widened) reopens it, and nothing else in
# the suite would notice.
RSpec.describe "the OmniAuth request phase", type: :request do
  def with_forgery_protection
    original = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    yield
  ensure
    ActionController::Base.allow_forgery_protection = original
  end

  it "does not hand a GET on the authorize path to Microsoft" do
    get "/users/auth/entra_id"

    expect(response).not_to be_redirect
    expect(response.headers["Location"].to_s).not_to include "login.microsoftonline.com"
  end

  it "accepts only POST on the authorize path" do
    authorize = Rails.application.routes.routes.find do |route|
      route.path.spec.to_s == "/users/auth/entra_id(.:format)"
    end

    expect(authorize).to be_present
    expect(authorize.verb).to eq "POST"
  end

  # The structural half of the guard: the gem installs itself by assigning
  # OmniAuth's request_validation_phase. Asserting on it means removing the gem
  # fails here loudly rather than quietly dropping token verification. The test
  # environment disables forgery protection, so a behavioural test alone would
  # pass with the gem gone.
  it "verifies the authenticity token in the request phase" do
    expect(OmniAuth.config.request_validation_phase)
      .to be_an_instance_of OmniAuth::RailsCsrfProtection::TokenVerifier
  end

  it "rejects a POST carrying no authenticity token" do
    with_forgery_protection do
      post "/users/auth/entra_id"
    end

    expect(response).not_to be_redirect
    expect(response.headers["Location"].to_s).not_to include "login.microsoftonline.com"
    expect(response.status).to be >= 400
  end
end
