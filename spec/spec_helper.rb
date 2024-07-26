require "simplecov"
SimpleCov.start "rails"

ENV["RAILS_ENV"] ||= "test"
ENV["ENV"] ||= "test"

require File.expand_path("../config/environment", __dir__)

require "rspec/rails"
require "./spec/support/features/session_helpers"
require "./spec/support/db_helpers"
require "paper_trail/frameworks/rspec"

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  mock_api_runner = PQA::MockApiServerRunner.new

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    mock_api_runner.start
  end

  config.after(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    mock_api_runner.stop
  end
end
