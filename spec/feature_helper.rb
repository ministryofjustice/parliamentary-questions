ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)

require './spec/support/features/session_helpers'
require './spec/support/db_helpers'
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'capybara/email/rspec'

Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, {
      phantomjs_logger: File.new('/dev/null', 'a')
    })
end

Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|
  config.include Features::SessionHelpers, type: :feature

  # Manage mock API server instance
  mock_api_runner = PQA::MockApiServerRunner.new


  # Set to false to enable Poltergeist
  #config.use_transactional_fixtures = false
  config.order = "random"
  #config.infer_spec_type_from_file_location!


  DatabaseCleaner.strategy = :truncation
  # Databse cleaner setup
  # Use truncation in js tests, transaction otherwise
  # source: http://devblog.avdi.org/2012/08/31/configuring-database_cleaner-with-rails-rspec-capybara-and-selenium/
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    mock_api_runner.start
  end

  config.before(:each) do |example|
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
    DBHelpers.load_seeds
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:suite) do
    mock_api_runner.stop
  end
end

