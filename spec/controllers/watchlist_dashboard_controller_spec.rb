require 'spec_helper'
require "#{Rails.root}/spec/support/features/session_helpers"

describe WatchlistDashboardController, type: :controller do

  describe 'GET index' do

    let(:entity)  { 'watchlist-20/05/2015 11:37' }
    let(:token)   { FactoryGirl.create :token, entity: entity }

    it 'should mark the token as accepted if not already acknowledged' do
      expect(AOTokenFilter).to receive(:validate_token).and_return(:valid)
      expect(token).not_to be_acknowledged      
      get :index, params
      expect(response.status).to eq(200)
      expect(token.reload).to be_acknowledged
    end
  end


end


def params
  {   
    "entity"=>"watchlist-20/05/2015 11:37",
    "amp"=>nil,
    "token"=>"_pC_wpsCpudnsYPbo_6f",
    "controller"=>"watchlist_dashboard",
    "action"=>"index"
  }
end