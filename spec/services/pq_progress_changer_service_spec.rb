require 'spec_helper'

describe 'PQProgressChangerService' do

  let(:action_officer) { create(:action_officer, name: 'ao name 1', email: 'ao@ao.gov') }
  let(:pq_1) { create(:PQ, uin: 'HL789', question: 'test question?') }
  let(:pq_2) { create(:PQ, uin: 'HL710', question: 'test question?') }
  progress_seed

#
#  Show Finance Check - If no finance view
#  Show PQ Commission - If finance have viewed
#  Show PQ draft - If AO has accepted
#  Show POD Check - If date set to pod complete
#  Show Minister Check -  If date cleared by POD complete
#  Show Answer - if date cleared by minister is complete
#
#  Show in Draft Pending - if - Allocated accepted  lower than at the beginning of the day.
#  Show in POD Waiting - If - ‘Date returned to action officer’ is completed - & remove from Draft Pending
#  Show in POD Query - if - POD query is selected - & remove from POD Waiting
#  Show in POD cleared - if - POD cleared’ is completed - & remove from POD Query
#  Show in Minister Waiting - If - 'Date sent to minister’ is completed - & remove from POD cleared (Both ministers if there are two)
#  Show in Minister Query - If - ‘Minister query’ is selected - & remove from Minister Waiting - (both ministers need to be completed if there are two)
#  Show in Minister Cleared - If - ‘Date cleared by minister’ is completed - & remove from Minister Query (Both ministers need to be cleared if there are two)
#
#  *Remove from dashboard - if - 'Date answer submitted to Q&A tool’ is completed - or- ‘Date PQ withdrawn’ is selected*

                                                                                                                                                                   Show in I Will Write - If - 'i will write’ is selected. - & maintain all other states.



  before(:each) do
    @pq_progress_changer_service = PQProgressChangerService.new
  end


  describe '#update_progress' do
    it 'WIP skel for test' do

      @pq_progress_changer_service.update_progress(pq_1, pq_1)

    end
  end
end