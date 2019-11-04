require 'spec_helper'

describe DeputyDirectorsController, type: :controller do
  describe 'Get index' do
    it 'lists the Deputy Directors sorted alphabetically (first name) by active then inactive states' do
      create_divisions_for_deputy_directors
      create_deputy_directors
      expect(PQUserFilter).to receive(:before).and_return(true)
      expect(controller).to receive(:authenticate_user!).and_return(true)
      get :index
      expect(response.status).to eq(200)
      expect(assigns(:deputy_directors).map(&:name)).to eq expected_order_of_deputy_directors
    end
  end
end

def create_deputy_directors
  FactoryBot.create(:deputy_director, name: 'Anna Maddox',      division_id: '2', updated_at: DateTime.now.to_datetime,  deleted: false)
  FactoryBot.create(:deputy_director, name: 'Evangeline Cowan', division_id: '1', updated_at: DateTime.now.to_datetime,  deleted: true)
  FactoryBot.create(:deputy_director, name: 'Lisa May',         division_id: '1', updated_at: 1.day.ago.to_datetime,     deleted: false)
  FactoryBot.create(:deputy_director, name: 'Sylvia Ware',      division_id: '2', updated_at: 1.day.ago.to_datetime,     deleted: true)
  FactoryBot.create(:deputy_director, name: 'Carrie Carroll',   division_id: '1', updated_at: 3.days.ago.to_datetime,    deleted: false)
  FactoryBot.create(:deputy_director, name: 'Armand Reid',      division_id: '2', updated_at: 3.days.ago.to_datetime,    deleted: true)
  FactoryBot.create(:deputy_director, name: 'Cecelia Barr',     division_id: '2', updated_at: DateTime.now.to_datetime,  deleted: false)
  FactoryBot.create(:deputy_director, name: 'Xavier Freeman',   division_id: '1', updated_at: DateTime.now.to_datetime,  deleted: true)
  FactoryBot.create(:deputy_director, name: 'Kent Holloway',    division_id: '1', updated_at: 1.day.ago.to_datetime,     deleted: false)
  FactoryBot.create(:deputy_director, name: 'Jae Young',        division_id: '2', updated_at: 1.day.ago.to_datetime,     deleted: true)
  FactoryBot.create(:deputy_director, name: 'Bill Estes',       division_id: '2', updated_at: 3.days.ago.to_datetime,    deleted: false)
  FactoryBot.create(:deputy_director, name: 'Jeramy Conner',    division_id: '2', updated_at: 3.days.ago.to_datetime,    deleted: true)
end

def create_divisions_for_deputy_directors
  FactoryBot.create(:division, id: '1', name: 'Division N')
  FactoryBot.create(:division, id: '2', name: 'Division M')
end

def expected_order_of_deputy_directors
  [
    'Anna Maddox',
    'Bill Estes',
    'Cecelia Barr',
    'Carrie Carroll',
    'Kent Holloway',
    'Lisa May',
    'Jae Young',
    'Sylvia Ware',
    'Evangeline Cowan',
    'Xavier Freeman'
  ]
end
