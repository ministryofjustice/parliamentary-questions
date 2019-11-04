require 'spec_helper'

describe DivisionsController, type: :controller do
  describe 'Get index' do
    it 'lists the Divisions sorted alphabetically by active then inactive states' do
      create_directorates_for_divisions
      create_divisions
      expect(PQUserFilter).to receive(:before).and_return(true)
      expect(controller).to receive(:authenticate_user!).and_return(true)
      get :index
      expect(response.status).to eq(200)
      expect(assigns(:divisions).map(&:name)).to eq expected_order_of_divisions
    end
  end
end

def create_directorates_for_divisions
  @div1 = FactoryBot.create(:directorate, name: 'Directorate A')
  @div2 = FactoryBot.create(:directorate, name: 'Directorate B')
end

def create_divisions
  FactoryBot.create(:division, name: 'Division A',  directorate_id: @div1.id, updated_at: DateTime.now.to_datetime,  deleted: false)
  FactoryBot.create(:division, name: 'Division B',  directorate_id: @div2.id, updated_at: DateTime.now.to_datetime,  deleted: true)
  FactoryBot.create(:division, name: 'Division C',  directorate_id: @div1.id, updated_at: 1.day.ago.to_datetime,     deleted: false)
  FactoryBot.create(:division, name: 'Division D',  directorate_id: @div2.id, updated_at: 1.day.ago.to_datetime,     deleted: true)
  FactoryBot.create(:division, name: 'Division E',  directorate_id: @div1.id, updated_at: 2.days.ago.to_datetime,    deleted: false)
  FactoryBot.create(:division, name: 'Division F',  directorate_id: @div2.id, updated_at: 2.days.ago.to_datetime,    deleted: true)
  FactoryBot.create(:division, name: 'Division G',  directorate_id: @div1.id, updated_at: DateTime.now.to_datetime,  deleted: false)
  FactoryBot.create(:division, name: 'Division H',  directorate_id: @div2.id, updated_at: DateTime.now.to_datetime,  deleted: true)
  FactoryBot.create(:division, name: 'Division I',  directorate_id: @div1.id, updated_at: 1.day.ago.to_datetime,     deleted: false)
  FactoryBot.create(:division, name: 'Division J',  directorate_id: @div2.id, updated_at: 1.day.ago.to_datetime,     deleted: true)
  FactoryBot.create(:division, name: 'Division K',  directorate_id: @div1.id, updated_at: 2.days.ago.to_datetime,    deleted: false)
  FactoryBot.create(:division, name: 'Division L',  directorate_id: @div2.id, updated_at: 2.days.ago.to_datetime,    deleted: true)
end

def expected_order_of_divisions
  [
    'Division A',
    'Division C',
    'Division E',
    'Division G',
    'Division I',
    'Division K',
    'Division B',
    'Division D',
    'Division H',
    'Division J'
  ]
end
