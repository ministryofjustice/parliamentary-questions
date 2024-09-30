require "rails_helper"

describe EarlyBirdDashboardController, type: :controller do
  let(:monday) { Date.new(2024, 9, 23) }
  let(:tuesday) { Date.new(2024, 9, 24) }

  describe "Get index" do
    before do
      allow(AoTokenFilter).to receive(:before).and_return(true)
    end

    it "Persists a session value for the dashboard" do
      expect(AoTokenFilter).to receive(:before)
      get :index, params: { token: "token123", entity: "entity123" }
      expect(response.status).to eq(200)
      expect(session[:early_bird_token]).to eq "token123"
      expect(session[:early_bird_entity]).to eq "entity123"
    end

    it "includes all new questions sorted by uin" do
      setup_questions(only_new: true)
      get :index, params: { token: "token123", entity: "entity123" }
      expect(assigns(:questions).map(&:uin)).to eq %w[uin-1 uin-2 uin-3 uin-4 uin-5 uin-6]
    end

    it "On a Monday it includes questions from Friday and new questions sorted by uin" do
      Timecop.freeze(monday) do
        setup_questions
        get :index, params: { token: "token123", entity: "entity123" }
        expect(assigns(:questions).map(&:uin)).to eq %w[uin-1 uin-2 uin-2a uin-3 uin-3a uin-4 uin-4a uin-5 uin-5a uin-6]
      end
    end

    it "On a Tuesday it includes questions from previous day and new questions sorted by uin" do
      Timecop.freeze(tuesday) do
        setup_questions
        get :index, params: { token: "token123", entity: "entity123" }
        expect(assigns(:questions).map(&:uin)).to eq %w[uin-1 uin-2 uin-2a uin-3 uin-4 uin-5 uin-5a uin-6]
      end
    end
  end

  def setup_questions(only_new: false)
    FactoryBot.create(:pq, uin: "uin-2")
    FactoryBot.create(:pq, uin: "uin-5")
    FactoryBot.create(:pq, uin: "uin-4", created_at: Time.zone.today - 1)
    FactoryBot.create(:pq, uin: "uin-3", created_at: Time.zone.today - 2)
    FactoryBot.create(:pq, uin: "uin-1", created_at: Time.zone.today - 3)
    FactoryBot.create(:pq, uin: "uin-6", created_at: Time.zone.today - 1000)
    unless only_new
      FactoryBot.create(:draft_pending_pq, uin: "uin-2a")
      FactoryBot.create(:draft_pending_pq, uin: "uin-5a")
      FactoryBot.create(:draft_pending_pq, uin: "uin-4a", created_at: Time.zone.today - 1)
      FactoryBot.create(:draft_pending_pq, uin: "uin-3a", created_at: Time.zone.today - 2)
      FactoryBot.create(:draft_pending_pq, uin: "uin-1a", created_at: Time.zone.today - 3)
      FactoryBot.create(:draft_pending_pq, uin: "uin-6a", created_at: Time.zone.today - 1000)
    end
  end
end
