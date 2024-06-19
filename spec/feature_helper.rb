ENV["RAILS_ENV"] ||= "test"
ENV["ENV"] ||= "test"

require File.expand_path("../config/environment", __dir__)

require "./spec/support/features/session_helpers"
require "./spec/support/features/pq_helpers"
require "./spec/support/db_helpers"
require "rspec/rails"
require "paper_trail/frameworks/rspec"
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

  # Start mock API server instance
  mock_api_runner = PQA::MockApiServerRunner.new

  # Database cleaner setup
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    mock_api_runner.start
  end

  # Use truncation in js tests and suspended tests, transaction otherwise
  config.before do |test|
    if test.metadata[:js]
      DatabaseCleaner.strategy = [
        :truncation,
      ]
    else
      DatabaseCleaner.strategy = [
        :transaction,
      ]
      DatabaseCleaner.start
    end
  end

  config.after do |test|
    DatabaseCleaner.clean
  end

  # Shut down mock API instance
  config.after(:suite) do
    mock_api_runner.stop
  end
end

ParliamentaryQuestions::Application.default_url_options = ParliamentaryQuestions::Application.config.action_mailer.default_url_options
