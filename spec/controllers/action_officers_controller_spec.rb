require "spec_helper"

describe ActionOfficersController, type: :controller do
  describe "Get index" do
    it "lists the action officers sorted alphabetically (first name) by active then inactive states" do
      create_divisions_for_deputy_directors
      create_deputy_directors_for_action_officers
      create_action_officers
      allow(PQUserFilter).to receive(:before).and_return(true)
      expect(PQUserFilter).to receive(:before)
      allow(controller).to receive(:authenticate_user!).and_return(true)
      expect(controller).to receive(:authenticate_user!)
      get :index
      expect(response.status).to eq(200)
      expect(assigns(:action_officers).map(&:name)).to eq expected_order_of_action_officers
    end
  end
end

def create_action_officers
  FactoryBot.create(:action_officer, name: "Anna Maddox",       deputy_director_id: "1", updated_at: Time.zone.now, deleted: false)
  FactoryBot.create(:action_officer, name: "Evangeline Cowan",  deputy_director_id: "2", updated_at: Time.zone.now, deleted: true)
  FactoryBot.create(:action_officer, name: "Lisa May",          deputy_director_id: "2", updated_at: 1.day.ago,    deleted: false)
  FactoryBot.create(:action_officer, name: "Sylvia Ware",       deputy_director_id: "1", updated_at: 1.day.ago,    deleted: true)
  FactoryBot.create(:action_officer, name: "Carrie Carroll",    deputy_director_id: "2", updated_at: 3.days.ago,   deleted: false)
  FactoryBot.create(:action_officer, name: "Armand Reid",       deputy_director_id: "1", updated_at: 3.days.ago,   deleted: true)
  FactoryBot.create(:action_officer, name: "Cecelia Barr",      deputy_director_id: "1", updated_at: Time.zone.now, deleted: false)
  FactoryBot.create(:action_officer, name: "Xavier Freeman",    deputy_director_id: "2", updated_at: Time.zone.now, deleted: true)
  FactoryBot.create(:action_officer, name: "Kent Holloway",     deputy_director_id: "2", updated_at: 1.day.ago,    deleted: false)
  FactoryBot.create(:action_officer, name: "Jae Young",         deputy_director_id: "1", updated_at: 1.day.ago,    deleted: true)
  FactoryBot.create(:action_officer, name: "Bill Estes",        deputy_director_id: "1", updated_at: 3.days.ago,   deleted: false)
  FactoryBot.create(:action_officer, name: "Jeramy Conner",     deputy_director_id: "1", updated_at: 3.days.ago,   deleted: true)
end

def create_deputy_directors_for_action_officers
  FactoryBot.create(:deputy_director, id: "1", name: "Randi Harding",      division_id: "2")
  FactoryBot.create(:deputy_director, id: "2", name: "Ernestine Santana",  division_id: "1")
end

def create_divisions_for_deputy_directors
  FactoryBot.create(:division, id: "1", name: "Division B")
  FactoryBot.create(:division, id: "2", name: "Division A")
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
