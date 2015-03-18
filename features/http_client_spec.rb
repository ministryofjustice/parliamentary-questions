require 'feature_helper'

describe HTTPClient do
  let(:default_settings) {[ 
      Settings.pq_rest_api.host,
      'username',
      'password',
      File.expand_path('resources/certs/wqa.parliament.uk.pem', __dir__)
  ]}

  let(:client)      { HTTPClient.new(*default_settings)                  }

  context 'issuing requests' do
    it 'should send a get request to the server' do
      res = client.issue_request(:get, "#{client.base_url}/")

      expect(res.code).to eq '200'
      expect(res.body).to eq 'This API is working'
    end

    it 'should create a put request' do
      res = client.issue_request(:put, "#{client.base_url}/reset")

      expect(res.code).to eq '200'
      expect(res.body).to eq 'ok'
    end

    it 'the put request can accept a request body as input' do
      q   = PQA::QuestionBuilder.default("uin-1")
      xml = PQA::XMLEncoder.encode_questions([q])
      uri = File.join(client.base_url, 'api/qais/questions', q.uin)
      res = client.issue_request(:put, uri, xml)

      expect(res.code).to eq '200'
      expect(res.body).to match(/status: #{q.question_status} => OK/)
    end
  end

  context 'authentication' do
    it 'should authenticate based on credentials provided' do
      expect_any_instance_of(Net::HTTP::Get).to receive(:basic_auth)
        .with('username', 'password')

      client.issue_request(:get, "#{client.base_url}/")
    end

    it 'should not verify SSL certificate when handling HTTP' do
      expect_any_instance_of(Net::HTTP).not_to receive(:use_ssl)

      client.issue_request(:get, "#{client.base_url}/")
    end
  end
end
