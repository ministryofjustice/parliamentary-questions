require "spec_helper"

describe MinistersController, type: :controller do
  describe "Get index" do
    it "lists the Ministers sorted alphabetically (first name) by active then inactive states" do
      create_ministers
      expect(PQUserFilter).to receive(:before).and_return(true)
      expect(controller).to receive(:authenticate_user!).and_return(true)
      get :index
      expect(response.status).to eq(200)
      expect(assigns(:ministers).map(&:name)).to eq expected_order_of_ministers
    end
  end
end

def create_ministers
  FactoryBot.create(:minister, name: "Anna Maddox",      updated_at: Time.zone.now.to_datetime, deleted: false)
  FactoryBot.create(:minister, name: "Evangeline Cowan", updated_at: Time.zone.now.to_datetime, deleted: true)
  FactoryBot.create(:minister, name: "Lisa May",         updated_at: 1.day.ago.to_datetime,    deleted: false)
  FactoryBot.create(:minister, name: "Sylvia Ware",      updated_at: 1.day.ago.to_datetime,    deleted: true)
  FactoryBot.create(:minister, name: "Carrie Carroll",   updated_at: 3.days.ago.to_datetime,   deleted: false)
  FactoryBot.create(:minister, name: "Armand Reid",      updated_at: 3.days.ago.to_datetime,   deleted: true)
  FactoryBot.create(:minister, name: "Cecelia Barr",     updated_at: Time.zone.now.to_datetime, deleted: false)
  FactoryBot.create(:minister, name: "Xavier Freeman",   updated_at: Time.zone.now.to_datetime, deleted: true)
  FactoryBot.create(:minister, name: "Kent Holloway",    updated_at: 1.day.ago.to_datetime,    deleted: false)
  FactoryBot.create(:minister, name: "Jae Young",        updated_at: 1.day.ago.to_datetime,    deleted: true)
  FactoryBot.create(:minister, name: "Bill Estes",       updated_at: 3.days.ago.to_datetime,   deleted: false)
  FactoryBot.create(:minister, name: "Jeramy Conner",    updated_at: 3.days.ago.to_datetime,   deleted: true)
end

def expected_order_of_ministers
  [
    "Anna Maddox",
    "Bill Estes",
    "Carrie Carroll",
    "Cecelia Barr",
    "Kent Holloway",
    "Lisa May",
    "Evangeline Cowan",
    "Jae Young",
    "Sylvia Ware",
    "Xavier Freeman",
  ]
end
