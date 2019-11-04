require 'spec_helper'
require "#{Rails.root}/spec/support/features/session_helpers"

describe PressOfficersController, type: :controller do
  describe 'Get index' do
    it 'lists the Press Officers sorted alphabetically (first name) by active then inactive states' do
      create_press_officers
      expect(PQUserFilter).to receive(:before).and_return(true)
      expect(controller).to receive(:authenticate_user!).and_return(true)
      get :index
      expect(response.status).to eq(200)
      expect(assigns(:press_officers).map(&:name)).to eq expected_order_of_press_officers
    end
  end
end

def create_press_officers
  FactoryBot.create(:press_officer, name: 'Anna Maddox',       updated_at: DateTime.now.to_datetime,  deleted: false)
  FactoryBot.create(:press_officer, name: 'Evangeline Cowan',  updated_at: DateTime.now.to_datetime,  deleted: true)
  FactoryBot.create(:press_officer, name: 'Lisa May',          updated_at: 1.day.ago.to_datetime,     deleted: false)
  FactoryBot.create(:press_officer, name: 'Sylvia Ware',       updated_at: 1.day.ago.to_datetime,     deleted: true)
  FactoryBot.create(:press_officer, name: 'Carrie Carroll',    updated_at: 2.days.ago.to_datetime,    deleted: false)
  FactoryBot.create(:press_officer, name: 'Armand Reid',       updated_at: 2.days.ago.to_datetime,    deleted: true)
  FactoryBot.create(:press_officer, name: 'Cecelia Barr',      updated_at: DateTime.now.to_datetime,  deleted: false)
  FactoryBot.create(:press_officer, name: 'Xavier Freeman',    updated_at: DateTime.now.to_datetime,  deleted: true)
  FactoryBot.create(:press_officer, name: 'Kent Holloway',     updated_at: 1.day.ago.to_datetime,     deleted: false)
  FactoryBot.create(:press_officer, name: 'Jae Young',         updated_at: 1.day.ago.to_datetime,     deleted: true)
  FactoryBot.create(:press_officer, name: 'Bill Estes',        updated_at: 2.days.ago.to_datetime,    deleted: false)
  FactoryBot.create(:press_officer, name: 'Jeramy Conner',     updated_at: 2.days.ago.to_datetime,    deleted: true)
end

def expected_order_of_press_officers
  [
    'Anna Maddox',
    'Bill Estes',
    'Carrie Carroll',
    'Cecelia Barr',
    'Kent Holloway',
    'Lisa May',
    'Evangeline Cowan',
    'Jae Young',
    'Sylvia Ware',
    'Xavier Freeman'
  ]
end
