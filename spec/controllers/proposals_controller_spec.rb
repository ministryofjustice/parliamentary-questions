require "rails_helper"

describe ProposalsController, type: :controller do
  describe "Get new" do
    let(:pq) { FactoryBot.create(:pq) }

    it "Assign pq" do
      get :new, params: { pq_id: pq.id }
      expect(assigns(:pq)).to eq(pq)
    end

    it "Assigns action officers" do
      allow(controller).to receive(:authenticate_user).and_return(true)
      expect(controller).to receive(:authenticate_user)
      action_officer = FactoryBot.create(:action_officer)
      get :new, params: { pq_id: pq.id }
      expect(assigns(:action_officers)).to eq([action_officer])
    end

    it "renders the new template" do
      allow(controller).to receive(:authenticate_user).and_return(true)
      expect(controller).to receive(:authenticate_user)
      get :new, params: { pq_id: pq.id }
      expect(response).to render_template("new")
    end
  end
end
