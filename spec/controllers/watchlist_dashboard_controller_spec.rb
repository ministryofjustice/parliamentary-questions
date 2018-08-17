require 'spec_helper'
require "#{Rails.root}/spec/support/features/session_helpers"

describe WatchlistDashboardController, type: :controller do

  before(:each) do
    @token_service = TokenService.new
  end

  describe 'GET index' do
    let(:entity) { 'watchlist-20/05/2015 11:37' }
    let(:token)  { FactoryBot.create :token, entity: entity }

    it 'The token should not be marked as acknowledged' do
      expect(token).to_not be_acknowledged
    end
  end

end
