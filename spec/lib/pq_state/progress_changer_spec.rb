require 'spec_helper'

describe 'PQState#progress_changer' do
  def stub_pq(overrides = {})
    double('test-pq',
           {
             no_response?: true,
             rejected?: false,
             action_officers_pqs: double('ao-pqs', any?: true, all_rejected?: false),
             action_officer_accepted: nil,
             transfer_out_ogd_id: nil
           }.merge(overrides)
          )
  end

  subject do
    PQState.progress_changer
  end

  describe '#validate_transition_graph!' do
    it 'should not raise errors' do
      expect do
        subject.validate_transition_graph!
      end.not_to raise_error
    end
  end

  describe '#next_state' do
    context 'when moving from the initial, to an intermediate state of the graph' do
      it 'returns the intermediate state' do
        expect(subject.next_state(PQState::UNASSIGNED, stub_pq)).to eq(PQState::NO_RESPONSE)
      end
    end

    context 'moving from an intermediate state to a possible final state' do
      it 'returns the final state' do
        pq = stub_pq(transfer_out_ogd_id: 'test-id',
                     transfer_out_date: DateTime.now)

        expect(subject.next_state(PQState::NO_RESPONSE, pq)).to eq(PQState::TRANSFERRED_OUT)
      end
    end

    context 'moving from the initialial to the final state' do
      it 'returns the final state' do
        pq = stub_pq(transfer_out_ogd_id: 'test-id',
                     transfer_out_date: DateTime.now,
                     action_officer_accepted: double('ao'),
                     draft_answer_received: DateTime.now,
                     pod_clearance: true,
                     policy_minister: nil,
                     answering_minister_query: false,
                     policy_minister_query: false,
                     sent_to_answering_minister: Time.zone.today,
                     cleared_by_answering_minister: true,
                     pq_withdrawn: true
                    )

        expect(subject.next_state(PQState::UNASSIGNED, pq)).to eq(PQState::ANSWERED)
      end
    end
  end
end
