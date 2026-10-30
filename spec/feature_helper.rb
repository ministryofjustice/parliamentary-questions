require "spec_helper"

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
end

ParliamentaryQuestions::Application.default_url_options = ParliamentaryQuestions::Application.config.action_mailer.default_url_options
