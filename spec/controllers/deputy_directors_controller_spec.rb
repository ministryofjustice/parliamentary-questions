require "rails_helper"

describe DeputyDirectorsController, type: :controller do
  describe "Get index" do
    it "lists the Deputy Directors sorted alphabetically (first name) by active then inactive states" do
      create_deputy_directors
      allow(PqUserFilter).to receive(:before).and_return(true)
      expect(PqUserFilter).to receive(:before)
      allow(controller).to receive(:authenticate_user!).and_return(true)
      expect(controller).to receive(:authenticate_user!)
      get :index
      expect(response.status).to eq(200)
      expect(assigns(:deputy_directors).map(&:name)).to eq expected_order_of_deputy_directors
    end
  end
end

def create_deputy_directors
  div1 = FactoryBot.create(:division, name: "Division N")
  div2 = FactoryBot.create(:division, name: "Division M")

  FactoryBot.create(:deputy_director, name: "Anna Maddox",      division: div2, updated_at: Time.zone.now, deleted: false)
  FactoryBot.create(:deputy_director, name: "Evangeline Cowan", division: div1, updated_at: Time.zone.now, deleted: true)
  FactoryBot.create(:deputy_director, name: "Lisa May",         division: div1, updated_at: 1.day.ago,    deleted: false)
  FactoryBot.create(:deputy_director, name: "Sylvia Ware",      division: div2, updated_at: 1.day.ago,    deleted: true)
  FactoryBot.create(:deputy_director, name: "Carrie Carroll",   division: div1, updated_at: 3.days.ago,   deleted: false)
  FactoryBot.create(:deputy_director, name: "Armand Reid",      division: div2, updated_at: 3.days.ago,   deleted: true)
  FactoryBot.create(:deputy_director, name: "Cecelia Barr",     division: div2, updated_at: Time.zone.now, deleted: false)
  FactoryBot.create(:deputy_director, name: "Xavier Freeman",   division: div1, updated_at: Time.zone.now, deleted: true)
  FactoryBot.create(:deputy_director, name: "Kent Holloway",    division: div1, updated_at: 1.day.ago,    deleted: false)
  FactoryBot.create(:deputy_director, name: "Jae Young",        division: div2, updated_at: 1.day.ago,    deleted: true)
  FactoryBot.create(:deputy_director, name: "Bill Estes",       division: div2, updated_at: 3.days.ago,   deleted: false)
  FactoryBot.create(:deputy_director, name: "Jeramy Conner",    division: div2, updated_at: 3.days.ago,   deleted: true)
end

def expected_order_of_deputy_directors
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
