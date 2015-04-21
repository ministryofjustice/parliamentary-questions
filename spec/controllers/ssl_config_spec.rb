require 'spec_helper'

describe DashboardController, type: :controller do
  before(:each) do
    allow(PQUserFilter).to receive(:before).and_return(true)
    allow(controller).to receive(:authenticate_user!).and_return(true)
  end

  describe 'ssl configuration in production' do
    it 'should force ssl' do
      allow(Rails.env).to receive(:production?).and_return(true)
        
      expect(controller).to receive(:force_ssl)
      expect(controller).not_to receive(:before_action).with(:reset_session, if: :ssl_excepted?)
      get :index
    end
  end

  describe 'ssl configuration not in production' do
    it 'should not force ssl on any routes' do
      allow(Rails.env).to receive(:production?).and_return(false)
      
      expect(controller).not_to receive(:force_ssl)
      expect(controller).to receive(:before_action).with(:reset_session, if: :ssl_excepted?)
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
      allow(Rails.env).to receive(:production?).and_return(true)
        
      expect(controller).not_to receive(:force_ssl)
      expect(controller).to receive(:before_action).with(:reset_session, if: :ssl_excepted?)
      get :index
    end
  end
end