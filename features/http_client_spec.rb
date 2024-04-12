require "feature_helper"

describe HTTPClient do
  let(:default_settings) do
    [
      Settings.pq_rest_api.host,
      "username",
      "password",
      File.expand_path("resources/certs/wqa.parliament.uk.pem", __dir__),
    ]
  end

  let(:client) { described_class.new(*default_settings) }

  context "when issuing requests" do
    it "sends a get request to the server" do
      res = client.issue_request(:get, "#{client.base_url}/")

      expect(res.code).to eq "200"
      expect(res.body).to eq "This API is working"
    end

    it "creates a put request" do
      res = client.issue_request(:put, "#{client.base_url}/reset")

      expect(res.code).to eq "200"
      expect(res.body).to eq "ok"
    end

    it "the put request can accept a request body as input" do
      q   = PQA::QuestionBuilder.default("uin-1")
      xml = PQA::XmlEncoder.encode_questions([q])
      uri = File.join(client.base_url, "api/qais/questions", q.uin)
      res = client.issue_request(:put, uri, xml)

      expect(res.code).to eq "200"
      expect(res.body).to match(/status: #{q.question_status} => OK/)
    end
  end

  context "when authenticating" do
    # rubocop:disable RSpec/AnyInstance
    it "authenticates based on credentials provided" do
      expect_any_instance_of(Net::HTTP::Get).to receive(:basic_auth)
        .with("username", "password")

      client.issue_request(:get, "#{client.base_url}/")
    end

    it "does not verify SSL certificate when handling HTTP" do
      expect_any_instance_of(Net::HTTP).not_to receive(:use_ssl)

      client.issue_request(:get, "#{client.base_url}/")
    end
    # rubocop:enable RSpec/AnyInstance
  end
end
