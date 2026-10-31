# rails_helper, not spec_helper: it is what calls
# config.infer_spec_type_from_file_location!, and without that these specs have
# no :feature type, so the type-scoped includes below never apply and the
# session helpers go missing. In a full suite run another spec loads
# rails_helper and it works by luck; running a feature spec on its own does
# not.
require "rails_helper"

require "./spec/support/features/pq_helpers"
require "capybara/rspec"
require "capybara/rails"

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  unless ENV["CHROME_DEBUG"]
    options.add_argument("--enable-features=NetworkService,NetworkServiceInProcess")
    options.add_argument("--guest")
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--start-maximized")
    options.add_argument("--window-size=1980,2080")
  end

  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

Capybara.javascript_driver = :headless_chrome

RSpec.configure do |config|
  # Helper modules to load
  #
  # SessionHelpers is scoped to feature specs, matching what rails_helper.rb
  # already does. Included globally it defines sign_in(email, password) in
  # every example group, which shadows Devise::Test::ControllerHelpers'
  # sign_in(resource) in controller specs — and only in a full run, because it
  # takes effect once any feature spec has loaded this file. That made a
  # controller spec pass alone and fail in the suite.
  config.include Features::SessionHelpers, type: :feature
  config.include Rails.application.routes.url_helpers
  config.include Capybara::DSL
  config.include Features::PqHelpers

  # Reset OmniAuth's mock between examples so a stubbed identity or failure
  # cannot leak into the next one.
  #
  # Scoped to feature specs deliberately: with test_mode on, OmniAuth
  # intercepts the callback path and hands back the mock, which would stop
  # spec/requests/omniauth_request_phase_spec.rb from being able to exercise a
  # real provider-reported failure.
  config.after(type: :feature) do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth.delete(:entra_id)
  end
end

ParliamentaryQuestions::Application.default_url_options = ParliamentaryQuestions::Application.config.action_mailer.default_url_options
