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

  # Rejected twice over, which is why this asserts on the outcome rather than a
  # status code. The request phase raises ActionController::InvalidAuthenticityToken,
  # OmniAuth turns that into a failure and Devise dispatches #failure — but it
  # re-uses the original POST env, which still carries no token, so
  # ApplicationController's `protect_from_forgery with: :exception` rejects it
  # again and the response is a 422 rather than a redirect to the error page.
  # That is the correct outcome for this request: it is the CVE-2015-9284
  # attack shape, not a user journey, and it fails closed. The user-facing
  # failure path arrives by GET and is covered below.
  it "rejects a POST carrying no authenticity token" do
    with_forgery_protection do
      post "/users/auth/entra_id"
    end

    expect(response).not_to be_redirect
    expect(response.headers["Location"].to_s).not_to include "login.microsoftonline.com"
    expect(response.status).to be >= 400
  end

  # The journey a real user takes when they click Cancel at the Microsoft
  # prompt: Entra redirects back to the callback by GET with an error
  # parameter. This is the end-to-end proof that a provider failure reaches
  # Users::OmniauthCallbacksController#failure and lands on the PQ error page,
  # which the controller spec cannot show because #failure has no route.
  it "sends a provider-reported error to the PQ sign-in failure page" do
    get "/users/auth/entra_id/callback?error=access_denied&error_description=user+cancelled"

    expect(response).to redirect_to sign_in_failed_path
  end

  it "does not echo the provider's error_description anywhere" do
    get "/users/auth/entra_id/callback?error=access_denied&error_description=<script>alert(1)</script>"

    follow_redirect!

    expect(response.body).not_to include "alert(1)"
  end
end
