require "spec_helper"

describe "AOTokenFilter" do
  before do
    @token_service = TokenService.new
  end

  describe ".validate_token" do
    it "the filter should say no access if you dont have a valid token" do
      controller = double("ApplicationController")
      request    = double("request")

      allow(request).to receive(:path).and_return("/test/this")
      allow(controller).to receive(:params).and_return({ token: "mytoken", entity: "test" })
      allow(controller).to receive(:request) { request }

      expect(AOTokenFilter.validate_token(controller)).to eq :invalid
    end

    it "the filter should pass if you have a valid token" do
      controller = double("ApplicationController")
      request    = double("request")
      path       = "/my/valid/path"
      entity     = "ao@justice.com"
      token      = @token_service.generate_token(path, entity, DateTime.now.at_end_of_day)

      allow(request).to receive(:path) { path }
      allow(controller).to receive(:params) { { token:, entity: } }
      allow(controller).to receive(:request) { request }

      expect(AOTokenFilter.validate_token(controller)).to eq :valid
    end

    it "the filter should fail if the token is expired" do
      controller = double("ApplicationController")
      request    = double("request")
      path       = "/my/valid/path"
      entity     = "ao@justice.com"
      token      = @token_service.generate_token(path, entity, 20.minutes.ago)

      allow(request).to receive(:path) { path }
      allow(controller).to receive(:params) { { token:, entity: } }
      allow(controller).to receive(:request) { request }

      expect(AOTokenFilter.validate_token(controller)).to eq :expired
    end

    it "the filter should say no access if you provide empty token" do
      controller = double("ApplicationController")
      request    = double("request")

      allow(request).to receive(:path).and_return("/test/this")
      allow(controller).to receive(:params).and_return({ entity: "test" })
      allow(controller).to receive(:request) { request }

      expect(AOTokenFilter.validate_token(controller)).to eq :invalid
    end

    it "the filter should say no access if you provide empty entity" do
      controller = double("ApplicationController")
      request    = double("request")

      allow(request).to receive(:path).and_return("/test/this")
      allow(controller).to receive(:params).and_return({ token: "test" })
      allow(controller).to receive(:request) { request }
    end

    it "the filter should say no access if you have a are in the wrong path" do
      controller = double("ApplicationController")
      request    = double("request")
      path       = "/my/valid/path"
      entity     = "ao@justice.com"
      token      = @token_service.generate_token(path, entity, DateTime.now.at_end_of_day)

      allow(request).to receive(:path).and_return("/other")
      allow(controller).to receive(:params) { { token:, entity: } }
      allow(controller).to receive(:request) { request }

      expect(AOTokenFilter.validate_token(controller)).to eq :invalid
    end
  end

  describe ".before" do
    let(:controller) { double("controller") }
    let(:user)       { double(User) }
    let(:request)    { double("request") }

    it "does not write an error log if valid" do
      expect(AOTokenFilter).to receive(:validate_token).and_return(:valid)
      expect(LogStuff).not_to receive(:error)

      AOTokenFilter.before(controller)
    end
  end
end
