require "spec_helper"

describe RakeTaskHelpers::StagingSync do
  # rubocop:disable RSpec/AnyInstance
  subject(:staging_sync) { described_class.new }

  before do
    ENV["TEST_USER_PASS"] = "xxx"
    allow($stdout).to receive(:puts)
    ENV["TEST_USER_PASS"] = "xxxx"
  end

  it "does not run unless the host env is staging " do
    allow(HostEnv).to receive(:is_staging?).and_return(false)
    msg =
      "[-] This task should only be run in the staging environment\n" \
      "[-] Database has NOT been modified\n"

    expect_any_instance_of(RakeTaskHelpers::DBSanitizer).not_to receive(:run!)
    expect_any_instance_of(RakeTaskHelpers::TestUserGenerator).not_to receive(:run!)
    expect { staging_sync.run! }.to output(msg).to_stdout
  end

  it "sanitizes the db and create test users on staging" do
    allow(HostEnv).to receive(:is_staging?).and_return(true)

    expect_any_instance_of(RakeTaskHelpers::DBSanitizer).to receive(:run!)
    expect_any_instance_of(RakeTaskHelpers::TestUserGenerator).to receive(:run!)

    staging_sync.run!
  end

  it "sends an email notification in case of failure" do
    allow(HostEnv).to receive(:is_staging?).and_return(true)
    allow_any_instance_of(RakeTaskHelpers::DBSanitizer).to receive(:run!).and_raise(StandardError)
    allow(NotifyDbSyncMailer).to receive_message_chain(:notify_fail, :deliver_later)

    staging_sync.run!

    expect(NotifyDbSyncMailer).to have_received(:notify_fail).with("StandardError")
  end
  # rubocop:enable RSpec/AnyInstance
end
