require "spec_helper"

describe HealthCheck::PQAApi do
  let(:pqa) { described_class.new }

  describe ".time_to_run?" do
    it "is true if the timestamp file does not exist" do
      delete_timestamp_file
      expect(described_class.time_to_run?).to be true
    end

    it "is true if the timestamp file contains a time more than 15 minutes ago" do
      Timecop.freeze(16.minutes.ago) { described_class.new.record_result }
      expect(described_class.time_to_run?).to be true
    end

    it "is false if the timestamp file contains a time less than 15 minutes ago" do
      Timecop.freeze(14.minutes.ago) { described_class.new.record_result }
      expect(described_class.time_to_run?).to be false
    end
  end

  # rubocop:disable RSpec/AnyInstance
  describe "#available?" do
    it "returns true if the parliamentary questions API is available" do
      expect(pqa).to be_available
    end

    it "returns false if the parliamentary questions API is not available" do
      allow_any_instance_of(Net::HTTP)
        .to receive(:request)
        .and_raise(Net::ReadTimeout)

      expect(pqa).not_to be_available
    end
  end

  describe "#accessible?" do
    let(:resp_403) { instance_double Net::HTTPResponse, code: 403, body: "unauthorised" }

    it "returns true if the parliamentary questions API is accessible with our credentials" do
      expect(pqa).to be_accessible
    end

    it "returns false if the parliamentary questions API is not accessible with our credentials" do
      allow_any_instance_of(Net::HTTP)
        .to receive(:request)
        .and_return(resp_403)

      expect(pqa).not_to be_accessible
    end
  end

  describe "#error_messages" do
    it "returns the exception messages if there is an error accessing the parliamentary questions API" do
      allow_any_instance_of(Net::HTTP)
        .to receive(:request)
        .and_raise(Errno::ECONNREFUSED)

      pqa.available?

      expect(pqa.error_messages).to eq ["PQA API Access Error: Connection refused"]
    end

    it "returns an error an backtrace for errors not specific to a component" do
      allow_any_instance_of(Net::HTTP)
        .to receive(:request)
        .and_raise(StandardError)

      pqa.available?

      expect(pqa.error_messages.first).to match(/Error: StandardError\nDetails/)
    end
  end
  # rubocop:enable RSpec/AnyInstance

  describe "#record_result" do
    it "writes timestamp and OK if no error messages" do
      Timecop.freeze(Time.utc(2015, 5, 8, 15, 35, 45)) do
        pqa.record_result
        expect(contents_of_timestamp_file).to eq "1431099345::OK::[]\n"
      end
    end

    it "writes timestamp and FAIL and error messages if any errors" do
      Timecop.freeze(Time.utc(2015, 5, 8, 15, 35, 45)) do
        pqa.instance_variable_set(:@errors, ["First error message", "Second error message"])
        pqa.record_result
        expect(contents_of_timestamp_file).to eq "1431099345::FAIL::[\"First error message\",\"Second error message\"]\n"
      end
    end
  end
end

def contents_of_timestamp_file
  File.open(HealthCheck::PQAApi::TIMESTAMP_FILE, "r", &:gets)
end

def delete_timestamp_file
  File.unlink(HealthCheck::PQAApi::TIMESTAMP_FILE) if File.exist?(HealthCheck::PQAApi::TIMESTAMP_FILE)
end
