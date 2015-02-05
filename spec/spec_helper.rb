require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'shoulda/matchers'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'capybara/email/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, {
      phantomjs_logger: File.new('/dev/null', 'a')
    })
end

Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|
  mock_api_runner = PQA::MockApiServerRunner.new

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rrAh OK
  config.include FactoryGirl::Syntax::Methods
  config.include Devise::TestHelpers, type: :controller

  config.include Features::SessionHelpers, type: :feature
  # config.include Features::DecisionHelpers, type: :feature
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.infer_spec_type_from_file_location!

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.clean
    DatabaseCleaner.strategy = :transaction

    mock_api_runner.start
    progress_seed
  end

  config.after(:suite) do
    mock_api_runner.stop
  end
end
