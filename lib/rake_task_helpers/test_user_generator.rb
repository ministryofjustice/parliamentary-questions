require 'yaml'

module RakeTaskHelpers
  class TestUserGenerator
    DEFAULT_CONFIG_PATH = "#{Rails.root}/lib/rake_task_helpers/test_user_config.yml"

    attr_reader :prefix, :default_pass, :testers

    def initialize(prefix, default_pass, testers)
      @prefix       = prefix
      @default_pass = default_pass
      @testers      = testers
    end

    def self.from_config(path = DEFAULT_CONFIG_PATH)
      raise 'TEST_USER_PASS environment variable not set - please set it first' unless ENV['TEST_USER_PASS']

      config = YAML.load(File.read(path))
      
      new(
        config['prefix'],
        ENV['TEST_USER_PASS'],
        config['testers'].map { |tester| OpenStruct.new(tester) } 
      )
    end

    def run!
      testers.each { |tester| create_fixtures_for(tester) }
    end

    private

    def create_fixtures_for(tester)
      u  =  User.find_or_create_by(
              email: email_for('u', tester), 
              name:  display_name(tester), 
              roles: 'PQUSER'
            )

      u.update(password: default_pass, password_confirmation: default_pass) if u.new_record?

      Minister.find_or_create_by(
        name:  display_name(tester), 
        title: prefix
      )

      p  = PressDesk.find_or_create_by(name: prefix)

      PressOfficer.find_or_create_by(
        name:       display_name(tester), 
        email:      email_for('po', tester), 
        press_desk: p 
      )

      dir = Directorate.find_or_create_by(name: prefix)

      div = Division.find_or_create_by(
              name: prefix, 
              directorate: dir
            )

      dd  = DeputyDirector.find_or_create_by( 
              division: Division.first, 
              email:    email_for('dd', tester), 
              name:     display_name(tester) 
            ) 

      ActionOfficer.find_or_create_by(
        deputy_director: dd, 
        name:            display_name(tester), 
        email:           email_for('ao', tester),
        press_desk:      p 
      )
    end

    def email_for(abbreviation, tester)
      "#{tester.email}+#{abbreviation}@#{tester.domain}"
    end

    def display_name(tester)
      "#{prefix} - #{tester.name}"
    end
  end
end