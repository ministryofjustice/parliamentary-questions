require "rails_helper"

describe ActionOfficersController, type: :controller do
  describe "Get index" do
    it "lists the action officers sorted alphabetically (first name) by active then inactive states" do
      create_action_officers
      allow(PqUserFilter).to receive(:before).and_return(true)
      expect(PqUserFilter).to receive(:before)
      allow(controller).to receive(:authenticate_user!).and_return(true)
      expect(controller).to receive(:authenticate_user!)
      get :index
      expect(response.status).to eq(200)
      expect(assigns(:action_officers).map(&:name)).to eq expected_order_of_action_officers
    end
  end
end

def create_action_officers
  div1 = FactoryBot.create(:division, id: "1", name: "Division B")
  div2 = FactoryBot.create(:division, id: "2", name: "Division A")
  dir1 = FactoryBot.create(:deputy_director, name: "Randi Harding", division: div2)
  dir2 = FactoryBot.create(:deputy_director, name: "Ernestine Santana", division: div1)

  FactoryBot.create(:action_officer, name: "Anna Maddox",       deputy_director: dir1, updated_at: Time.zone.now, deleted: false)
  FactoryBot.create(:action_officer, name: "Evangeline Cowan",  deputy_director: dir2, updated_at: Time.zone.now, deleted: true)
  FactoryBot.create(:action_officer, name: "Lisa May",          deputy_director: dir2, updated_at: 1.day.ago,    deleted: false)
  FactoryBot.create(:action_officer, name: "Sylvia Ware",       deputy_director: dir1, updated_at: 1.day.ago,    deleted: true)
  FactoryBot.create(:action_officer, name: "Carrie Carroll",    deputy_director: dir2, updated_at: 3.days.ago,   deleted: false)
  FactoryBot.create(:action_officer, name: "Armand Reid",       deputy_director: dir1, updated_at: 3.days.ago,   deleted: true)
  FactoryBot.create(:action_officer, name: "Cecelia Barr",      deputy_director: dir1, updated_at: Time.zone.now, deleted: false)
  FactoryBot.create(:action_officer, name: "Xavier Freeman",    deputy_director: dir2, updated_at: Time.zone.now, deleted: true)
  FactoryBot.create(:action_officer, name: "Kent Holloway",     deputy_director: dir2, updated_at: 1.day.ago,    deleted: false)
  FactoryBot.create(:action_officer, name: "Jae Young",         deputy_director: dir1, updated_at: 1.day.ago,    deleted: true)
  FactoryBot.create(:action_officer, name: "Bill Estes",        deputy_director: dir1, updated_at: 3.days.ago,   deleted: false)
  FactoryBot.create(:action_officer, name: "Jeramy Conner",     deputy_director: dir1, updated_at: 3.days.ago,   deleted: true)
end

def expected_order_of_action_officers
  [
    "Anna Maddox",
    "Bill Estes",
    "Cecelia Barr",
    "Carrie Carroll",
    "Kent Holloway",
    "Lisa May",
    "Jae Young",
    "Sylvia Ware",
    "Evangeline Cowan",
    "Xavier Freeman",
  ]
end
