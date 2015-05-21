require 'spec_helper'

describe SmokeTest do
  before(:each) do
    ENV['SENDING_HOST']   = 'http://localhost'
    ENV['TEST_USER']      = 'me'
    ENV['TEST_USER_PASS'] = '123'
  end

  it '#factory - creates an array of all smoke tests' do
    tests = subject.factory

    expect(tests[0]).to be_an_instance_of SmokeTest::Dashboard
    expect(tests[1]).to be_an_instance_of SmokeTest::Report
    expect(tests[2]).to be_an_instance_of SmokeTest::Statistics
  end

  context 'Base' do
    let(:test) { SmokeTest::Base.from_env}

    it '#from_env - should create an instance based on environment variables' do
      expect(test.instance_variable_get(:@user)).to eq 'me'
      expect(test.instance_variable_get(:@pass)).to eq '123'
      expect(test.instance_variable_get(:@app_uri).host).to eq 'localhost'
    end

    it '#passed? - logs into the application and calls all_checks_succeed?' do
      expect(test).to receive(:login_to_app)
      expect(test).to receive(:all_checks_succeed?).and_return(true)
      expect(test.passed?).to be true
    end

    it '#passed? - returns false if an error is raised' do
      expect(test).to receive(:login_to_app).and_raise(StandardError)

      expect(test.passed?).to be false
    end
  end
end