require 'spec_helper'

describe ProposalsController, type: :controller do
  describe 'Get new' do
    it 'Assigns action officers' do
      get :new, params: { pq_id: 1 }
      # expect(assigns(:action_officers).map(&:name)).to eq expected_order_of_action_officers
      expect(assigns(:action_officers)).to be_an_instance_of Array
    end
  end


end    