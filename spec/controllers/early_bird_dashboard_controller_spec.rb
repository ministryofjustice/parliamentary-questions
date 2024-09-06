require "rails_helper"

describe EarlyBirdDashboardController, type: :controller do
  describe "Get index" do
    before { create(:pq) }

    it "Persists a session value for the dashboard" do
      allow(AoTokenFilter).to receive(:before).and_return(true)
      expect(AoTokenFilter).to receive(:before)
      get :index, params: { token: "token123", entity: "entity123" }
      expect(response.status).to eq(200)
      expect(session[:early_bird_token]).to eq "token123"
      expect(session[:early_bird_entity]).to eq "entity123"
    end
  end
end
