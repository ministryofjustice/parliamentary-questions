require "spec_helper"

describe Settings do
  before do
    ENV["PQ_REST_API_HOST"]     = "api_host"
    ENV["PQ_REST_API_USERNAME"] = "username"
    ENV["PQ_REST_API_PASSWORD"] = "password"
  end

  context "when PQ Rest API is called" do
    describe ".from_env" do
      it "calls new with environment variables" do
        expect(Settings::PqRestApi).to receive(:new).with("api_host", "username", "password")
        Settings::PqRestApi.from_env
      end

      it "raises if the api-host environment var is not set" do
        ENV["PQ_REST_API_HOST"] = nil
        expect {
          Settings::PqRestApi.from_env
        }.to raise_error RuntimeError, "Cannot find environment variable PQ_REST_API_HOST. Please set it first"
      end
    end
  end

  context "when settings file values" do
    describe ".live_url" do
      it "returns the value from the file" do
        expect(described_class.live_url).to eq "https://trackparliamentaryquestions.service.gov.uk"
      end
    end

    describe ".mail_from" do
      it "returns the value from the file" do
        expect(described_class.mail_from).to eq "PQ Team <no-reply@trackparliamentaryquestions.service.gov.uk>"
      end
    end

    describe ".mail_reply_to" do
      it "returns the value from the file" do
        expect(described_class.mail_reply_to).to eq "pqs@justice.gov.uk"
      end
    end

    describe ".mail_tech_support" do
      it "returns the value from the file" do
        expect(described_class.mail_tech_support).to eq "pqsupport@digital.justice.gov.uk"
      end
    end

    describe ".http_client_timeout" do
      it "returns the value from the file" do
        expect(described_class.http_client_timeout).to eq 20
      end
    end

    describe ".commission_mail_from" do
      it "returns the value from the file" do
        expect(described_class.commission_mail_from).to eq "PQ Team <no-reply@trackparliamentaryquestions.service.gov.uk>"
      end
    end

    describe "non existent config key" do
      it "raises NoMethodError" do
        expect {
          described_class.unknown_config_key
        }.to raise_error NoMethodError, "undefined method `unknown_config_key' for Settings:Module"
      end
    end
  end

  context "when checking the MailWorker" do
    describe ".pid_filepath" do
      it "returns the value from the file" do
        expect(described_class.mail_worker.pid_filepath).to eq "/tmp/mail_worker.pid"
      end
    end

    describe ".max_fail_count" do
      it "returns the value from the file" do
        expect(described_class.mail_worker.max_fail_count).to eq 15
      end
    end

    describe ".timeout" do
      it "returns the value from the file" do
        expect(described_class.mail_worker.timeout).to eq 300
      end
    end
  end

  context "when Smoke Test Runner run" do
    describe ".out_file" do
      it "returns the value in the file" do
        expect(described_class.smoke_test_runner.out_file).to eq "/tmp/smoke_test_run"
      end
    end
  end
end
