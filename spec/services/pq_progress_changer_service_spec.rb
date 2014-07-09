require 'spec_helper'

describe 'PQProgressChangerService' do

  let(:action_officer) { create(:action_officer, name: 'ao name 1', email: 'ao@ao.gov') }
  let(:pq_1) { create(:PQ, uin: 'HL789', question: 'test question?') }
  let(:pq_2) { create(:PQ, uin: 'HL710', question: 'test question?') }
  progress_seed

  before(:each) do
    @pq_progress_changer_service = PQProgressChangerService.new
  end


  describe '#update_progress' do
    it 'WIP skel for test' do

      @pq_progress_changer_service.update_progress(pq_1, pq_1)

    end
  end
end