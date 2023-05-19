require 'spec_helper'

describe 'QuickActionsService' do
  let!(:pq) { create(:pq) }
  let!(:pq2) { create(:pq) }

  let!(:pq_with_state) { create(:draft_pending_pq) }
  let!(:pq_with_minister) { create(:with_minister_pq) }
  let!(:pq_with_state2) { create(:draft_pending_pq) }

  before(:each) do
    @quick_actions_service = QuickActionsService.new
    @pqs_array = []
    @pqs_array.push(pq)
    @pq_list = pq.uin
  end

  it "Doesn't validate a list with any invalid PQ" do
    expect(@quick_actions_service.valid_pq_list('HL789, some rubbish here,or there')).to eq(false)
  end
  it 'Validates a single PQ' do
    expect(@quick_actions_service.valid_pq_list(@pq_list)).to eq(@pqs_array)
  end

  context 'Update dates is run' do
    it "Doesn't validate a list of valid PQs with invalid internal_deadline" do
      expect(@quick_actions_service.valid?(@pq_list, '0/0/0000')).to eq(false)
    end
    it "Doesn't validate a list of valid PQs with invalid draft_received" do
      expect(@quick_actions_service.valid?(@pq_list, '01/10/2015', '0/0/0000')).to eq(false)
    end
    it "Doesn't validate a list of valid PQs with invalid pod_clearance" do
      expect(@quick_actions_service.valid?(@pq_list, '01/10/2015', '01/10/2015', '0/0/0000')).to eq(false)
    end
    it "Doesn't validate a list of valid PQs with invalid minister_cleared" do
      expect(@quick_actions_service.valid?(@pq_list, '01/10/2015', '01/10/2015', '01/10/2015', '0/0/0000')).to eq(false)
    end
    it "Doesn't validate a list of valid PQs with invalid answered" do
      expect(@quick_actions_service.valid?(@pq_list, '01/10/2015', '01/10/2015', '01/10/2015', '01/10/2015', '0/0/0000')).to eq(false)
    end
    it 'Does validate a list of valid PQs with all valid dates' do
      @pqs_array2 = []
      @pqs_array2.push(pq)
      @pqs_array2.push(pq2)
      @pq_list = "#{pq.uin},#{pq2.uin}"
      expect(@quick_actions_service.valid?(@pq_list, '01/10/2015', '01/10/2015', '01/10/2015', '01/10/2015', '01/10/2015')).to eq(@pqs_array2)
    end
    it 'updates internal_deadline date for a list of valid pqs.' do
      pq_list = "#{pq.uin},#{pq2.uin},#{pq_with_state.uin}"
      @quick_actions_service.update_pq_list(pq_list, '21/01/2016', '', '', '', '')
      result_pq = Pq.find_by(uin: pq_with_state.uin)
      expect(result_pq.internal_deadline).to eq('21/01/2016')
    end

    # Internal deadline does not change question state - the following dates do...

    it 'updates draft_answer_received date and therefore state for a list of valid pqs.' do
      pq_list = "#{pq.uin},#{pq2.uin},#{pq_with_state.uin}"
      @quick_actions_service.update_pq_list(pq_list, '21/01/2016', '22/01/2016', '', '', '')
      result_pq = Pq.find_by(uin: pq_with_state.uin)
      expect(result_pq.draft_answer_received).to eq('22/01/2016')
      expect(result_pq.state).to eq('with_pod')
    end
    it 'updates pod_clearance date and therefore state for a list of valid pqs.' do
      pq_list = "#{pq.uin},#{pq2.uin},#{pq_with_state.uin}"
      @quick_actions_service.update_pq_list(pq_list, '21/01/2016', '22/01/2016', '23/01/2016', '', '')
      result_pq = Pq.find_by(uin: pq_with_state.uin)
      expect(result_pq.pod_clearance).to eq('23/01/2016')
      expect(result_pq.state).to eq('pod_cleared')
    end
    it 'updates cleared_by_answering_minister date and therefore state for a list of valid pqs.' do
      pq_list = "#{pq.uin},#{pq2.uin},#{pq_with_minister.uin}"
      # Business rule - sent_to_answering_minister must be set before a state change to cleared_by_answering minister is possible
      @quick_actions_service.update_pq_list(pq_list, '21/01/2016', '22/01/2016', '23/01/2016', '24/01/2016', '')
      result_pq = Pq.find_by(uin: pq_with_minister.uin)
      expect(result_pq.cleared_by_answering_minister).to eq('24/01/2016')
      expect(result_pq.state).to eq('minister_cleared')
    end
    it 'updates answer_submitted date and therefore state for a list of valid pqs.' do
      pq_list = "#{pq.uin},#{pq2.uin},#{pq_with_minister.uin}"
      # Business rule - sent_to_answering_minister must be set before a state change to answered is possible
      @quick_actions_service.update_pq_list(pq_list, '21/01/2016', '22/01/2016', '23/01/2016', '24/01/2016', '25/01/2016')
      result_pq = Pq.find_by(uin: pq_with_minister.uin)
      expect(result_pq.answer_submitted).to eq('25/01/2016')
      expect(result_pq.state).to eq('answered')
    end
  end
  context 'Send Draft Reminders' do
    it 'Gets action officer association of an accepted Pq' do
      expect(@quick_actions_service.get_action_officer_pqs_id(pq_with_state).to_s).to eq(pq_with_state.action_officers_pqs.find(&:accepted?).id.to_s)
    end
    it "doesn't crash for a pq that has not been accepted" do
      expect(@quick_actions_service.get_action_officer_pqs_id(pq).to_s).to eq(nil.to_s)
    end
    it 'Mails the draft reminder to the Action officer who accepted a question' do
      @pqs_array2 = []
      @pqs_array2.push(pq_with_state)
      expect(@quick_actions_service.mail_reminders(@pqs_array2)).to eq([pq_with_state])
    end
    it 'Mails the draft reminder to the Action officer who accepted a question' do
      @pqs_array2 = []
      @pqs_array2.push(pq_with_state)
      @pqs_array2.push(pq_with_state2)
      expect(@quick_actions_service.mail_reminders(@pqs_array2)).to eq(@pqs_array2)
    end

    it 'Takes a comma separated pq list and mails the Action Officers of Accepted Questions' do
      @pqs_array2 = []
      @pqs_array2.push(pq_with_state)
      @pqs_array2.push(pq_with_state2)
      @pq_list = "#{pq_with_state.uin},#{pq_with_state2.uin}"
      expect(@quick_actions_service.mail_draft_list(@pq_list)).to eq(@pqs_array2)
    end
  end
end
