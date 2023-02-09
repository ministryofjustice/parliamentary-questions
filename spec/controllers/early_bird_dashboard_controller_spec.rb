require 'spec_helper'

describe EarlyBirdDashboardController, type: :controller do
  describe 'Get index' do
    let!(:pq) { create(:pq) }

    it 'Persists a session value for the dashboard' do
      get :index, params: { token: 'token123', entity: 'entity123' }
      expect(session[:early_bird_token]).not_to be_nil
    end
  end
end
