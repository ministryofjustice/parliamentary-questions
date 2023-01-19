require 'spec_helper'

describe ProposalsController, type: :controller do
  describe 'Get new' do
    let!(:pq) { FactoryBot.create(:pq) }
    it 'Assigns action officers' do
      action_officer = FactoryBot.create(:action_officer)
      get :new, params: { pq_id: pq.id }
      expect(assigns(:action_officers)).to eq([action_officer])
    end

    it "renders the new template" do
      get :new, params: { pq_id: pq.id }
      expect(response).to render_template("new")
    end
  end

  describe 'Get propose' do

  end
end