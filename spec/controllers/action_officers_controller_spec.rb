require 'spec_helper'

describe ActionOfficersController, type: :controller do
  describe 'Get index' do
    let!(:ao_1) { create :action_officer, name: 'Anna Maddox',        deputy_director_id: dd_1.id, updated_at: DateTime.now.to_datetime,  deleted: false }
    let!(:ao_2) { create :action_officer, name: 'Evangeline Cowan',   deputy_director_id: dd_2.id, updated_at: DateTime.now.to_datetime,  deleted: true }
    let!(:ao_3) { create :action_officer, name: 'Lisa May',           deputy_director_id: dd_2.id, updated_at: 1.day.ago.to_datetime,     deleted: false }
    let!(:ao_4) { create :action_officer, name: 'Sylvia Ware',        deputy_director_id: dd_1.id, updated_at: 1.day.ago.to_datetime,     deleted: true }
    let!(:ao_5) { create :action_officer, name: 'Carrie Carroll',     deputy_director_id: dd_2.id, updated_at: 2.days.ago.to_datetime,    deleted: false }
    let!(:ao_6) { create :action_officer, name: 'Armand Reid',        deputy_director_id: dd_1.id, updated_at: 2.days.ago.to_datetime,    deleted: true }
    let!(:ao_7) { create :action_officer, name: 'Cecelia Barr',       deputy_director_id: dd_1.id, updated_at: DateTime.now.to_datetime,  deleted: false }
    let!(:ao_8) { create :action_officer, name: 'Xavier Freeman',     deputy_director_id: dd_2.id, updated_at: DateTime.now.to_datetime,  deleted: true }
    let!(:ao_9) { create :action_officer, name: 'Kent Holloway',      deputy_director_id: dd_2.id, updated_at: 1.day.ago.to_datetime,     deleted: false }
    let!(:ao_10) { create :action_officer, name: 'Jae Young',         deputy_director_id: dd_1.id, updated_at: 1.day.ago.to_datetime,     deleted: true }
    let!(:ao_11) { create :action_officer, name: 'Bill Estes',        deputy_director_id: dd_1.id, updated_at: 2.days.ago.to_datetime,    deleted: false }
    let!(:ao_12) { create :action_officer, name: 'Jeramy Conner',     deputy_director_id: dd_1.id, updated_at: 2.days.ago.to_datetime,    deleted: true }

    let(:dd_1) { create :deputy_director, name: 'Randi Harding',      division_id: div_2.id }
    let(:dd_2) { create :deputy_director, name: 'Ernestine Santana',  division_id: div_1.id }

    let(:div_1) { create :division, name: 'Division N' }
    let(:div_2) { create :division, name: 'Division M' }

    it 'lists the action officers sorted alphabetically (first name) by active then inactive states' do
      # create_divisions_for_action_officers
      # create_deputy_directors_for_action_officers
      # create_action_officers

      expect(PQUserFilter).to receive(:before).and_return(true)
      expect(controller).to receive(:authenticate_user!).and_return(true)
      get :index
      expect(response.status).to eq(200)

      expect(assigns(:action_officers).map(&:name)).to eq expected_order_of_action_officers
    end
  end

  # def create_action_officers
  #   FactoryBot.create(:action_officer, name: 'Anna Maddox',       deputy_director_id: '1', updated_at: DateTime.now.to_datetime,  deleted: false)
  #   FactoryBot.create(:action_officer, name: 'Evangeline Cowan',  deputy_director_id: '2', updated_at: DateTime.now.to_datetime,  deleted: true)
  #   FactoryBot.create(:action_officer, name: 'Lisa May',          deputy_director_id: '2', updated_at: 1.day.ago.to_datetime,     deleted: false)
  #   FactoryBot.create(:action_officer, name: 'Sylvia Ware',       deputy_director_id: '1', updated_at: 1.day.ago.to_datetime,     deleted: true)
  #   FactoryBot.create(:action_officer, name: 'Carrie Carroll',    deputy_director_id: '2', updated_at: 2.days.ago.to_datetime,    deleted: false)
  #   FactoryBot.create(:action_officer, name: 'Armand Reid',       deputy_director_id: '1', updated_at: 2.days.ago.to_datetime,    deleted: true)
  #   FactoryBot.create(:action_officer, name: 'Cecelia Barr',      deputy_director_id: '1', updated_at: DateTime.now.to_datetime,  deleted: false)
  #   FactoryBot.create(:action_officer, name: 'Xavier Freeman',    deputy_director_id: '2', updated_at: DateTime.now.to_datetime,  deleted: true)
  #   FactoryBot.create(:action_officer, name: 'Kent Holloway',     deputy_director_id: '2', updated_at: 1.day.ago.to_datetime,     deleted: false)
  #   FactoryBot.create(:action_officer, name: 'Jae Young',         deputy_director_id: '1', updated_at: 1.day.ago.to_datetime,     deleted: true)
  #   FactoryBot.create(:action_officer, name: 'Bill Estes',        deputy_director_id: '1', updated_at: 2.days.ago.to_datetime,    deleted: false)
  #   FactoryBot.create(:action_officer, name: 'Jeramy Conner',     deputy_director_id: '1', updated_at: 2.days.ago.to_datetime,    deleted: true)
  # end

  # def create_deputy_directors_for_action_officers
  # end

  # def create_divisions_for_action_officers
  # end

  def expected_order_of_action_officers
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
end
