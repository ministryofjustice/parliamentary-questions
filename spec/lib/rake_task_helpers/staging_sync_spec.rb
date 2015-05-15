require 'spec_helper'

describe RakeTaskHelpers::StagingSync do
  before(:each) do
    ENV['TEST_USER_PASS']='xxx'
    allow($stdout).to receive(:puts)
  end

  it 'should not run unless the host env is staging ' do
    allow(HostEnv).to receive(:is_staging?).and_return(false)
    msg = 
      "[-] This task should only be run in the staging environment\n" + 
      "[-] Database has NOT been modified\n"

    expect_any_instance_of(RakeTaskHelpers::DBSanitizer).not_to receive(:run!)
    expect_any_instance_of(RakeTaskHelpers::TestUserGenerator).not_to receive(:run!)
    expect { subject.run! }.to output(msg).to_stdout
  end

  it 'should sanitize the db and create test users on staging' do
    allow(HostEnv).to receive(:is_staging?).and_return(true)

    expect_any_instance_of(RakeTaskHelpers::DBSanitizer).to receive(:run!)
    expect_any_instance_of(RakeTaskHelpers::TestUserGenerator).to receive(:run!)

    subject.run!
  end

  it 'should send an email notification in case of failure' do
    allow(HostEnv).to receive(:is_staging?).and_return(true)
    allow_any_instance_of(RakeTaskHelpers::DBSanitizer).to receive(:run!).and_raise(StandardError)

    subject.run!
    email = sent_mail.first
    
    expect(email.to).to include Settings.mail_tech_support
    expect(email.subject).to match /Staging DB sanitization failed/
    expect(email.body).to match /StandardError/
  end
end
