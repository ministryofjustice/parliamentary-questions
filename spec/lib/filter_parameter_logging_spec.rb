require "spec_helper"

# Asserted on BEHAVIOUR rather than on the contents of
# config.filter_parameters, because Rails matches these entries by SUBSTRING.
# The existing list already carries `token` and `secret`, which between them
# cover id_token, access_token, refresh_token and client_secret — so a test
# that checked the array for those literal symbols would fail while the
# parameters were in fact protected, and could pass while they were not.
RSpec.describe "parameter filtering" do
  let(:filter) { ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters) }

  def filtered(key)
    filter.filter(key => "SENSITIVE")[key]
  end

  # The authorization code is the one that matters most: it is a replayable
  # credential for its lifetime, and without this it lands in the Rails access
  # log on every single sign-in.
  it "filters the authorization code" do
    expect(filtered("code")).to eq "[FILTERED]"
  end

  it "filters the state parameter" do
    expect(filtered("state")).to eq "[FILTERED]"
  end

  it "filters the id token" do
    expect(filtered("id_token")).to eq "[FILTERED]"
  end

  it "filters the access token" do
    expect(filtered("access_token")).to eq "[FILTERED]"
  end

  it "filters the refresh token" do
    expect(filtered("refresh_token")).to eq "[FILTERED]"
  end

  it "filters the client secret" do
    expect(filtered("client_secret")).to eq "[FILTERED]"
  end

  it "still filters passwords" do
    expect(filtered("password")).to eq "[FILTERED]"
  end

  # Nested parameters are filtered too, which is the shape a token actually
  # arrives in when a provider response is logged.
  it "filters credentials nested inside other parameters" do
    result = filter.filter("provider" => { "code" => "abc", "access_token" => "xyz" })

    expect(result["provider"]).to eq("code" => "[FILTERED]", "access_token" => "[FILTERED]")
  end
end
