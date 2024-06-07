require "spec_helper"

describe DivisionsController, type: :controller do
  describe "Get index" do
    it "lists the Divisions sorted alphabetically by active then inactive states" do
      create_directorates_for_divisions
      create_divisions
      allow(PqUserFilter).to receive(:before).and_return(true)
      expect(PqUserFilter).to receive(:before)
      allow(controller).to receive(:authenticate_user!).and_return(true)
      expect(controller).to receive(:authenticate_user!)
      get :index
      expect(response.status).to eq(200)
      expect(assigns(:divisions).map(&:name)).to eq expected_order_of_divisions
    end
  end
end

def create_directorates_for_divisions
  FactoryBot.create(:directorate, id: "1", name: "Directorate A")
  FactoryBot.create(:directorate, id: "2", name: "Directorate B")
end

def create_divisions
  FactoryBot.create(:division, name: "Division A",  directorate_id: "1", updated_at: Time.zone.now, deleted: false)
  FactoryBot.create(:division, name: "Division B",  directorate_id: "2", updated_at: Time.zone.now, deleted: true)
  FactoryBot.create(:division, name: "Division C",  directorate_id: "1", updated_at: 1.day.ago,    deleted: false)
  FactoryBot.create(:division, name: "Division D",  directorate_id: "2", updated_at: 1.day.ago,    deleted: true)
  FactoryBot.create(:division, name: "Division E",  directorate_id: "1", updated_at: 3.days.ago,   deleted: false)
  FactoryBot.create(:division, name: "Division F",  directorate_id: "2", updated_at: 3.days.ago,   deleted: true)
  FactoryBot.create(:division, name: "Division G",  directorate_id: "1", updated_at: Time.zone.now, deleted: false)
  FactoryBot.create(:division, name: "Division H",  directorate_id: "2", updated_at: Time.zone.now, deleted: true)
  FactoryBot.create(:division, name: "Division I",  directorate_id: "1", updated_at: 1.day.ago,    deleted: false)
  FactoryBot.create(:division, name: "Division J",  directorate_id: "2", updated_at: 1.day.ago,    deleted: true)
  FactoryBot.create(:division, name: "Division K",  directorate_id: "1", updated_at: 3.days.ago,   deleted: false)
  FactoryBot.create(:division, name: "Division L",  directorate_id: "2", updated_at: 3.days.ago,   deleted: true)
end

def expected_order_of_divisions
  [
    "Division A",
    "Division C",
    "Division E",
    "Division G",
    "Division I",
    "Division K",
    "Division B",
    "Division D",
    "Division H",
    "Division J",
  ]
end
