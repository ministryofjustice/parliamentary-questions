require "rails_helper"

describe DivisionsController, type: :controller do
  describe "Get index" do
    it "lists the Divisions sorted alphabetically by active then inactive states" do
      create_divisions
      allow(controller).to receive(:authenticate_user!).and_return(true)
      expect(controller).to receive(:authenticate_user!)
      get :index
      expect(response.status).to eq(200)
      expect(assigns(:divisions).map(&:name)).to eq expected_order_of_divisions
    end
  end
end

def create_divisions
  dir1 = FactoryBot.create(:directorate)
  dir2 = FactoryBot.create(:directorate)

  FactoryBot.create(:division, name: "Division A",  directorate: dir1, updated_at: Time.zone.now, deleted: false)
  FactoryBot.create(:division, name: "Division B",  directorate: dir2, updated_at: Time.zone.now, deleted: true)
  FactoryBot.create(:division, name: "Division C",  directorate: dir1, updated_at: 1.day.ago,    deleted: false)
  FactoryBot.create(:division, name: "Division D",  directorate: dir2, updated_at: 1.day.ago,    deleted: true)
  FactoryBot.create(:division, name: "Division E",  directorate: dir1, updated_at: 3.days.ago,   deleted: false)
  FactoryBot.create(:division, name: "Division F",  directorate: dir2, updated_at: 3.days.ago,   deleted: true)
  FactoryBot.create(:division, name: "Division G",  directorate: dir1, updated_at: Time.zone.now, deleted: false)
  FactoryBot.create(:division, name: "Division H",  directorate: dir2, updated_at: Time.zone.now, deleted: true)
  FactoryBot.create(:division, name: "Division I",  directorate: dir1, updated_at: 1.day.ago,    deleted: false)
  FactoryBot.create(:division, name: "Division J",  directorate: dir2, updated_at: 1.day.ago,    deleted: true)
  FactoryBot.create(:division, name: "Division K",  directorate: dir1, updated_at: 3.days.ago,   deleted: false)
  FactoryBot.create(:division, name: "Division L",  directorate: dir2, updated_at: 3.days.ago,   deleted: true)
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
