require 'yaml'

require_relative 'tester'

module RakeTaskHelpers
  class TestUserGenerator
    DEFAULT_CONFIG_PATH = "#{Rails.root}/lib/rake_task_helpers/test_user_config.yml"

    attr_reader :testers

    def self.from_config(path = DEFAULT_CONFIG_PATH)
      raise 'TEST_USER_PASS environment variable not set - please set it first' unless ENV['TEST_USER_PASS']

      config       = YAML.safe_load(File.read(path))
      default_pass = ENV.fetch('TEST_USER_PASS', nil)
      prefix       = config['prefix']

      new(
        FullTester.factory(
          config['full_testers'],
          default_pass,
          prefix
        ) +
        RestrictedTester.factory(
          config['restricted_testers'],
          default_pass,
          prefix
        )
      )
    end

    def run!
      testers.each(&:create_fixtures!)
    end

    private

    def initialize(testers)
      @testers = testers
    end
  end
end
