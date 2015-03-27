require 'spec_helper'

describe 'AOTokenFilter' do

  before(:each) do
    @token_service = TokenService.new
  end

  describe '.validate_token' do
    it 'the filter should say no access if you dont have a valid token' do
      controller = double('ApplicationController')
      request = double('request')

      allow(request).to receive(:path) { '/test/this' }
      allow(controller).to receive(:params) { {token: 'mytoken', entity: 'test'} }
      allow(controller).to receive(:request) { request }

      expect(AOTokenFilter.validate_token(controller)).to eq :invalid
    end

    it 'the filter should pass if you have a valid token' do
      controller = double('ApplicationController')
      request = double('request')

      path = '/my/valid/path'
      entity = 'ao@justice.com'

      token = @token_service.generate_token(path, entity, DateTime.now.at_end_of_day)

      allow(request).to receive(:path) { path }
      allow(controller).to receive(:params) { {token: token, entity: entity} }
      allow(controller).to receive(:request) { request }

      expect(AOTokenFilter.validate_token(controller)).to eq :valid
    end


    it 'the filter should fail if the token is expired' do
      controller = double('ApplicationController')
      request = double('request')

      path = '/my/valid/path'
      entity = 'ao@justice.com'

      token = @token_service.generate_token(path, entity, 20.minutes.ago)

      allow(request).to receive(:path) { path }
      allow(controller).to receive(:params) { {token: token, entity: entity} }
      allow(controller).to receive(:request) { request }

      expect(AOTokenFilter.validate_token(controller)).to eq :expired
    end

    it 'the filter should say no access if you provide empty token' do
      controller = double('ApplicationController')
      request = double('request')

      allow(request).to receive(:path) { '/test/this' }
      allow(controller).to receive(:params) { { entity: 'test'} }
      allow(controller).to receive(:request) { request }

      expect(AOTokenFilter.validate_token(controller)).to eq :invalid
    end

    it 'the filter should say no access if you provide empty entity' do
      controller = double('ApplicationController')
      request = double('request')

      allow(request).to receive(:path) { '/test/this' }
      allow(controller).to receive(:params) { { token: 'test'} }
      allow(controller).to receive(:request) { request }
    end
      

    it 'the filter should say no access if you have a are in the wrong path' do
      controller = double('ApplicationController')
      request = double('request')

      path = '/my/valid/path'
      entity = 'ao@justice.com'

      token = @token_service.generate_token(path, entity, DateTime.now.at_end_of_day)

      allow(request).to receive(:path) { '/other' }
      allow(controller).to receive(:params) { {token: token, entity: entity} }
      allow(controller).to receive(:request) { request }

      expect(AOTokenFilter.validate_token(controller)).to eq :invalid
    end
  end


  describe '.before' do

    let(:controller)      { double('controller') }
    let(:user)            { double(User) }
    let(:request)         { double('request') }

    it 'should not write an error log if valid' do
      expect(AOTokenFilter).to receive(:validate_token).and_return(:valid)
      expect(LogStuff).not_to receive(:error)
      AOTokenFilter.before(controller)
    end


    it 'should write an error log if invalid' do
      set_logging_expectations
      expect(AOTokenFilter).to receive(:validate_token).and_return(:invalid)
      
      expect(LogStuff).to receive(:error).with(
          :token_error,
          type: "invalid_token",
          uri: 'http://pq.com/uri',
          referer: 'http://pq.com/referer',
          uin: 'uin-999',
          user: 'Joe Blow'
        )

      expect(controller).to receive(:render).with({:file => 'shared/token_invalid.html.slim', :status => :unauthorized})
      AOTokenFilter.before(controller)
    end

    it 'should write an error log if expired' do
      set_logging_expectations
      expect(AOTokenFilter).to receive(:validate_token).and_return(:expired)
      
      expect(LogStuff).to receive(:error).with(
          :token_error,
          type: "expired_token",
          uri: 'http://pq.com/uri',
          referer: 'http://pq.com/referer',
          uin: 'uin-999',
          user: 'Joe Blow'
        )

      expect(controller).to receive(:render).with({:file => 'shared/token_expired.html.slim', :status => :unauthorized})
      AOTokenFilter.before(controller)
    end
  end

end


def set_logging_expectations
  allow(controller).to receive(:env).and_return( 
    { 
      'REQUEST_URI' => 'http://pq.com/uri',
      'REQUEST_PATH' => '/assignment/uin-999',
    } 
  )
  allow(controller).to receive(:current_user).and_return(user)
  expect(user).to receive(:name).and_return('Joe Blow')
  expect(controller).to receive(:request).and_return(request)
  expect(request).to receive(:referer).and_return('http://pq.com/referer')
end
