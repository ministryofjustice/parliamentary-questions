require 'spec_helper'

describe EarlyBirdDashboardController, type: :controller do
  describe 'Get index' do
    let!(:pq) { create(:pq) }

    it 'Persists a session value for the dashboard' do
      expect(AOTokenFilter).to receive(:before).and_return(true)
      get :index, params: { token: 'token123', entity: 'entity123' }
      expect(response.status).to eq(200)
      expect(session[:early_bird_token]).to eq 'token123'
      expect(session[:early_bird_entity]).to eq 'entity123'
    end
  end
end
