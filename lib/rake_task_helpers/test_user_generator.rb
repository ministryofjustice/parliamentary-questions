require 'yaml'

require_relative 'tester'

module RakeTaskHelpers
  class TestUserGenerator
    DEFAULT_CONFIG_PATH = "#{Rails.root}/lib/rake_task_helpers/test_user_config.yml"

    attr_reader :testers

    def self.from_config(path = DEFAULT_CONFIG_PATH)
      unless ENV['TEST_USER_PASS']
        raise 'TEST_USER_PASS environment variable not set - please set it first' 
      end

      config       = YAML.load(File.read(path))
      default_pass = ENV['TEST_USER_PASS']
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
      testers.each { |tester| tester.create_fixtures! }
    end

    private 

    def initialize(testers)
      @testers = testers
    end
  end
end