require 'spec_helper'
require "#{Rails.root}/lib/rake_task_helpers/test_user_generator.rb"

describe RakeTaskHelpers::TestUserGenerator do
  let(:path) { "#{Rails.root}/spec/lib/rake_task_helpers/sample_config.yml" } 
  let(:gen)  { RakeTaskHelpers::TestUserGenerator.from_config(path)         }

  before(:each) do
    ENV['TEST_USER_PASS'] = 'password'
  end

  it 'should load data from the provided config file' do
    tester = gen.testers.first

    expect(tester.prefix).to eq 'TEST'
    expect(tester.name).to eq 'tester'
    expect(tester.email).to eq 'tester1'
    expect(tester.domain).to eq 'digital.justice.gov.uk'
  end

  it 'should create the records for a tester in the database' do
    gen.run!

    # Restricted Testers
    expect(User.find_by(name: 'TEST - tester2').email).to eq 'tester2@justice.gsi.gov.uk'

    # Full Testers
    expect(User.find_by(name: 'TEST - tester').email).to eq 'tester1+u@digital.justice.gov.uk'
    expect(Minister.find_by(name: 'TEST - tester').title).to eq 'TEST'
    expect(PressOfficer.find_by(name: 'TEST - tester').email).to eq 'tester1+po@digital.justice.gov.uk'
    expect(DeputyDirector.find_by(name: 'TEST - tester').email).to eq 'tester1+dd@digital.justice.gov.uk'
    expect(ActionOfficer.find_by(name: 'TEST - tester').email).to eq 'tester1+ao@digital.justice.gov.uk'
  end

  it 'should raise an error if the TEST_USER_PASS env variable is not set' do
    ENV['TEST_USER_PASS'] = nil

    expect { RakeTaskHelpers::TestUserGenerator.from_config }.to raise_error(RuntimeError)
  end
end