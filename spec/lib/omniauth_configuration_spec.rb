require "spec_helper"

RSpec.describe "OmniAuth configuration" do
  it "registers the Entra ID provider" do
    expect(User.omniauth_providers).to include(:entra_id)
  end

  # This is the guard that keeps a trivially forgeable identity out of every
  # deployed environment. It must stay in the suite permanently.
  it "does not register the developer strategy outside development" do
    expect(Rails.env.development?).to be false
    expect(User.omniauth_providers).not_to include(:developer)
  end

  it "exposes an authorize route for the provider" do
    expect(Rails.application.routes.url_helpers.user_entra_id_omniauth_authorize_path)
      .to eq "/users/auth/entra_id"
  end

  it "exposes the provider's callback route" do
    expect(Rails.application.routes.url_helpers.user_entra_id_omniauth_callback_path)
      .to eq "/users/auth/entra_id/callback"
  end

  it "configures the provider with the tenant from Settings" do
    expect(Devise.omniauth_configs[:entra_id].strategy_class)
      .to eq OmniAuth::Strategies::EntraId
  end

  it "requests only the OIDC scopes, with no Microsoft Graph permissions" do
    expect(Devise.omniauth_configs[:entra_id].options[:scope])
      .to eq "openid profile email"
  end

  # The gem's default uid is `tid + oid` concatenated. We store the bare oid in
  # users.azure_oid, so uid must agree with it.
  it "treats the bare oid as the uid" do
    expect(Devise.omniauth_configs[:entra_id].options[:ignore_tid]).to be true
  end
end
