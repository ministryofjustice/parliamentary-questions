require 'spec_helper'

describe ApplicationController, type: :controller do
  describe '#ssl_excepted?' do
    it 'should return true if we are on an excepted path' do

    end

    it 'should return false if we are not in an excepted path' do

    end
  end
end

describe DashboardController, type: :controller do
  before(:each) do
    allow(PQUserFilter).to receive(:before).and_return(true)
    allow(controller).to receive(:authenticate_user!).and_return(true)
  end

  describe 'ssl configuration in production' do
    it 'should force ssl' do
      # allow(PQUserFilter).to receive(:before).and_return(true)
      # allow(controller).to receive(:authenticate_user!).and_return(true)
      expect(Rails.env).to receive(:production?).and_return(true)
        
      expect(controller).to receive(:force_ssl)
      expect(controller).not_to receive(:before).with(:reset_session)
      get :index
    end
  end

  describe 'ssl configuration not in production' do
    it 'should not force ssl on any routes' do
      expect(Rails.env).to receive(:production?).and_return(false)
      
      expect(controller).not_to receive(:force_ssl)
      # expect(controller).to receive(:before).with(:reset_session)      ============> I don't think we expect this, do we?
      get :index
    end
  end
end

describe PingController, type: :controller do
  before(:each) do
    allow(PQUserFilter).to receive(:before).and_return(true)
    allow(controller).to receive(:authenticate_user!).and_return(true)
  end

  describe 'ssl configuration in production' do
    it 'should not force ssl on excepted routes, but reset the session' do
      expect(Rails.env).to receive(:production?).and_return(true)
      allow(request).to receive(:fullpath).and_return('ping.json')
        
      expect(controller).not_to receive(:force_ssl)
      expect(controller).to receive(:reset_session)
      get :index
    end
  end
end