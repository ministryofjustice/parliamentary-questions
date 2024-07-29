require "spec_helper"

describe EarlyBirdDashboardController, type: :controller do
  describe "Get index" do
    before do
      setup_questions
      allow(AoTokenFilter).to receive(:before).and_return(true)
    end

    it "Persists a session value for the dashboard" do
      expect(AoTokenFilter).to receive(:before)
      get :index, params: { token: "token123", entity: "entity123" }
      expect(response.status).to eq(200)
      expect(session[:early_bird_token]).to eq "token123"
      expect(session[:early_bird_entity]).to eq "entity123"
    end

    it "only includes todays questions and sorts the new questions by uin" do
      get :index, params: { token: "token123", entity: "entity123" }
      expect(assigns(:questions).map(&:uin)).to eq %w[uin-1 uin-2 uin-3 uin-5]
    end
  end

  def setup_questions
    FactoryBot.create(:pq, uin: "uin-2")
    FactoryBot.create(:pq, uin: "uin-5")
    FactoryBot.create(:pq, uin: "uin-4", created_at: Time.zone.today - 1)
    FactoryBot.create(:pq, uin: "uin-3")
    FactoryBot.create(:pq, uin: "uin-1")
    FactoryBot.create(:pq, uin: "uin-6", created_at: Time.zone.today - 1000)
  end
end
