require "spec_helper"
require "#{Rails.root.join('spec/support/features/session_helpers')}"

describe WatchlistDashboardController, type: :controller do
  before do
    @token_service = TokenService.new
  end

  describe "GET index" do
    let(:entity) { "watchlist-20/05/2015 11:37" }
    let(:token)  { FactoryBot.create :token, entity: }

    it "The token should not be marked as acknowledged" do
      expect(token).not_to be_acknowledged
    end
  end
end
