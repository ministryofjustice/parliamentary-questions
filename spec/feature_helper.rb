require "spec_helper"

require "./spec/support/features/pq_helpers"
require "capybara/rspec"
require "capybara/rails"

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  unless ENV["CHROME_DEBUG"]
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--start-maximized")
    options.add_argument("--window-size=1980,2080")
    options.add_argument("--enable-features=NetworkService,NetworkServiceInProcess")
  end

  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

Capybara.javascript_driver = :headless_chrome

RSpec.configure do |config|
  # Helper modules to load
  config.include Features::SessionHelpers
  config.include Rails.application.routes.url_helpers
  config.include Capybara::DSL
  config.include Features::PqHelpers

  config.before(js: true) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
    DatabaseCleaner.start
  end

  config.after(js: true) do
    DatabaseCleaner.clean
  end
end

ParliamentaryQuestions::Application.default_url_options = ParliamentaryQuestions::Application.config.action_mailer.default_url_options
