unless ENV["COVERAGE"].nil?
  require "simplecov"
  SimpleCov.start "rails" do
  end
end

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

::Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec
    # with.test_framework :minitest
    # with.test_framework :minitest_4
    # with.test_framework :test_unit

    # Choose one or more libraries:
    with.library :active_record
    with.library :active_model
    # with.library :action_controller

    # Or, choose the following (which implies all of the above):
    # with.library :rails
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

  # Databse cleaner setup
  # Use truncation in js tests, transaction otherwise
  # source: http://devblog.avdi.org/2012/08/31/configuring-database_cleaner-with-rails-rspec-capybara-and-selenium/
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction
    DBHelpers.load_spec_fixtures
  end

  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end
end

RSpec::Matchers.define :be_a_multiple_of do |expected|
  match do |actual|
    actual % expected == 0
  end
end

# match a GeckoStatus object with ['Component Name', "label", 'color', message]
# message parameter can either be a string or a regex
RSpec::Matchers.define :eq_gecko_status do |component_name, label, color, message|
  match do |actual|
    result = true
    result = false if actual.component_name != component_name
    result = false if actual.label != label
    result = false if actual.color != color
    if message.is_a?(Regexp)
      result = false if actual.message !~ message
    elsif actual.message != message
      result = false
    end
    result
  end
end
