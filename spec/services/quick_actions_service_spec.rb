require 'spec_helper'

describe 'QuickActionsService' do

  before(:each) do
    @quick_actions_service               = QuickActionsService.new
  end

    it "Validates a real PQ" do
      pq_list = 'one'
      internal_deadline = 'two'
      date_for_answer = 'three'

    expect(@quick_actions_service.valid?(pq_list, internal_deadline, date_for_answer)).to eq(true)
  end
end
