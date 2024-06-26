require "simplecov"
SimpleCov.start "rails"

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"
ENV["ENV"] ||= "test"

require File.expand_path("../config/environment", __dir__)

require "rspec/rails"
require "./spec/support/db_helpers"
require "./spec/support/features/session_helpers"
require "./spec/support/unit/question_factory"
require "./spec/support/csv_helpers"
require "shoulda/matchers"
require "paper_trail/frameworks/rspec"
require "sinatra"

require "bundler/setup"
::Bundler.require(:default, :test)

ActiveRecord::Migration.maintain_test_schema!

::Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rrAh OK
  config.include FactoryBot::Syntax::Methods
  # config.include Devise::TestHelpers, type: :controller

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Features::SessionHelpers, type: :feature

  # config.include Features::DecisionHelpers, type: :feature

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = Rails.root.join("spec/fixtures").to_s

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # Set to false to enable Poltergeist
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you  can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.infer_spec_type_from_file_location!

  # Start mock API server instance
  mock_api_runner = PQA::MockApiServerRunner.new

  # Databse cleaner setup
  config.before(:suite) do
    mock_api_runner.start
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around do |example|
    DatabaseCleaner.cleaning { example.run }
  end

  config.after(:suite) do
    mock_api_runner.stop
  end
end

RSpec::Matchers.define :be_a_multiple_of do |expected|
  match do |actual|
    actual % expected == 0
  end
end
