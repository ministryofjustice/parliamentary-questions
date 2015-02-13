ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)

require './spec/support/features/session_helpers'
require './spec/support/db_helpers'
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, {
    phantomjs_logger: File.new('/dev/null', 'a'),
    window_size: [1024, 1500]
  })
end

Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|
  # Test Order
  # config.order = "random"

  # Helper modules to load
  config.include Features::SessionHelpers, type: :feature

  # Start mock API server instance
  mock_api_runner = PQA::MockApiServerRunner.new

  # Database cleaner setup
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    mock_api_runner.start
    DBHelpers.load_feature_fixtures
  end

  # Tables to except from truncation
  TABLE_EXCEPTIONS = [
    Progress,
    Minister,
    Directorate,
    Division,
    DeputyDirector,
    PressDesk,
    PressOfficer,
    ActionOfficer,
    Ogd
  ].map(&:table_name)

  # Use truncation in js tests, transaction otherwise
  config.before(:each) do |test|
    if test.metadata[:js]
      DatabaseCleaner.strategy = [
        :truncation,
        { except: TABLE_EXCEPTIONS } 
      ]
    else
      DatabaseCleaner.strategy = [
        :transaction
      ]
    end

    DatabaseCleaner.start unless test.metadata[:suspend_cleaner]
  end

  config.after(:each) do |test|
    DatabaseCleaner.clean unless test.metadata[:suspend_cleaner]
  end

  # Shut down mock API instance
  config.after(:suite) do
    mock_api_runner.stop
  end
end

