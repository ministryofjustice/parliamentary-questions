require 'spec_helper'

describe 'PQProgressChangerService' do

  let(:action_officer) { create(:action_officer, name: 'ao name 1', email: 'ao@ao.gov') }
  let(:pq_1) { create(:PQ, uin: 'HL789', question: 'test question?') }
  let(:pq_2) { create(:PQ, uin: 'HL710', question: 'test question?') }
  progress_seed



#  Initial state 'Draft Pending' (done by the import process)
#
#  POD Waiting - if date 'draft_answer_received'is completed  && 'Draft Pending'
#
#  POD Query - if 'pod_query_flag == true' && 'POD Waiting'
#
#  POD Cleared - if - POD cleared’ is completed - & remove from POD Query
#  Show in Minister Waiting - If - 'Date sent to minister’ is completed - & remove from POD cleared (Both ministers if there are two)
#  Show in Minister Query - If - ‘Minister query’ is selected - & remove from Minister Waiting - (both ministers need to be completed if there are two)
#  Show in Minister Cleared - If - ‘Date cleared by minister’ is completed - & remove from Minister Query (Both ministers need to be cleared if there are two)
#
#  *Remove from dashboard - if - 'Date answer submitted to Q&A tool’ is completed - or- ‘Date PQ withdrawn’ is selected*

# Show in I Will Write - If - 'i will write’ is selected. - & maintain all other states.



  before(:each) do
    @pq_progress_changer_service = PQProgressChangerService.new
  end


  describe '#update_progress' do
    it 'WIP skel for test' do

      @pq_progress_changer_service.update_progress(pq_1, pq_1)

    end
  end
end