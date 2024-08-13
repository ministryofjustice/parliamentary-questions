require "rails_helper"

describe AoTokenFilter, type: :request do
  let(:token_service) { TokenService.new }

  describe ".validate_token" do
    it "the filter should say no access if you dont have a valid token" do
      allow(request).to receive(:path).and_return("/test/this")
      allow(controller).to receive(:params).and_return({ token: "mytoken", entity: "test" })
      allow(controller).to receive(:request) { request }

      expect(described_class.validate_token(controller)).to eq :invalid
    end

    it "the filter should pass if you have a valid token" do
      path = "/my/valid/path"
      entity = "ao@justice.com"
      token = token_service.generate_token(path, entity, Time.zone.now.at_end_of_day)

      allow(request).to receive(:path) { path }
      allow(controller).to receive(:params) { { token:, entity: } }
      allow(controller).to receive(:request) { request }

      expect(described_class.validate_token(controller)).to eq :valid
    end

    it "the filter should fail if the token is expired" do
      path = "/my/valid/path"
      entity = "ao@justice.com"
      token = token_service.generate_token(path, entity, 20.minutes.ago)

      allow(request).to receive(:path) { path }
      allow(controller).to receive(:params) { { token:, entity: } }
      allow(controller).to receive(:request) { request }

      expect(described_class.validate_token(controller)).to eq :expired
    end

    it "the filter should say no access if you provide empty token" do
      allow(request).to receive(:path).and_return("/test/this")
      allow(controller).to receive(:params).and_return({ entity: "test" })
      allow(controller).to receive(:request) { request }

      expect(described_class.validate_token(controller)).to eq :invalid
    end

    it "the filter should say no access if you provide empty entity" do
      allow(request).to receive(:path).and_return("/test/this")
      allow(controller).to receive(:params).and_return({ token: "test" })
      allow(controller).to receive(:request) { request }

      expect(described_class.validate_token(controller)).to eq :invalid
    end

    it "the filter should say no access if you have a are in the wrong path" do
      path = "/my/valid/path"
      entity = "ao@justice.com"
      token = token_service.generate_token(path, entity, Time.zone.now.at_end_of_day)

      allow(request).to receive(:path).and_return("/other")
      allow(controller).to receive(:params) { { token:, entity: } }
      allow(controller).to receive(:request) { request }

      expect(described_class.validate_token(controller)).to eq :invalid
    end
  end

  describe ".before" do
    let(:user) { instance_double(User) }

    it "does not write an error log if valid" do
      allow(described_class).to receive(:validate_token).and_return(:valid)
      expect(described_class).to receive(:validate_token)
      expect(LogStuff).not_to receive(:error)

      described_class.before(controller)
    end
  end
end
