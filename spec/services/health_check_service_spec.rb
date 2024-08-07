require "rails_helper"

describe HealthCheckService do
  context "when the PQA API is run" do
    # rubocop:disable RSpec/StubbedMock
    # rubocop:disable RSpec/AnyInstance
    it "calls accessible and avaiable on all checks" do
      allow(HealthCheck::PQAApi).to receive(:time_to_run?).and_return(true)
      expect(HealthCheck::PQAApi).to receive(:time_to_run?)
      expect_any_instance_of(HealthCheck::Database).to receive(:available?).and_return(true)
      expect_any_instance_of(HealthCheck::PQAApi).to receive(:available?).and_return(true)
      expect_any_instance_of(HealthCheck::Database).to receive(:accessible?).and_return(true)
      expect_any_instance_of(HealthCheck::PQAApi).to receive(:accessible?).and_return(true)

      result = described_class.new.report

      expect(result.status).to eq "200"
      expect(result.messages).to eq "All Components OK"
    end

    it "does not call accessible and available on PQA API check if not time to run" do
      allow(HealthCheck::PQAApi).to receive(:time_to_run?).and_return(false)
      expect(HealthCheck::PQAApi).to receive(:time_to_run?)
      expect_any_instance_of(HealthCheck::Database).to receive(:available?).and_return(true)
      expect_any_instance_of(HealthCheck::Database).to receive(:accessible?).and_return(true)
      expect_any_instance_of(HealthCheck::PQAApi).not_to receive(:available?)
      expect_any_instance_of(HealthCheck::PQAApi).not_to receive(:accessible?)

      result = described_class.new.report

      expect(result.status).to eq "200"
      expect(result.messages).to eq "All Components OK"
    end

    it "collects error messages if any checks fail" do
      allow(HealthCheck::PQAApi).to receive(:time_to_run?).and_return(true)
      expect(HealthCheck::PQAApi).to receive(:time_to_run?)
      expect_any_instance_of(HealthCheck::Database).to receive(:available?).and_return(false)
      expect_any_instance_of(HealthCheck::Database).to receive(:accessible?).and_return(false)
      expect_any_instance_of(HealthCheck::Database).to receive(:error_messages).and_return(["DB message 1", "DB Message 2"])
      expect_any_instance_of(HealthCheck::PQAApi).to receive(:available?).and_return(false)
      expect_any_instance_of(HealthCheck::PQAApi).to receive(:accessible?).and_return(false)
      expect_any_instance_of(HealthCheck::PQAApi).to receive(:error_messages).and_return(["API message 1", "API Message 2"])

      result = described_class.new.report

      expect(result.status).to eq "500"
      expect(result.messages.sort).to eq([
        "DB message 1",
        "DB Message 2",
        "API message 1",
        "API Message 2",
      ].sort)
    end
    # rubocop:enable RSpec/StubbedMock
    # rubocop:enable RSpec/AnyInstance
  end
end
