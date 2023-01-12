require 'spec_helper'

describe ProposalService do
  shared_context 'test_values' do
    let(:ao1)                 { DBHelpers.action_officers[0] }
    let(:ao2)                 { DBHelpers.action_officers[1] }
    let(:form)                { ProposalForm.new(form_params) }
    let(:invalid_form_params) { form_params.merge(action_officer_id: ['']) }
    let(:invalid_form)        { ProposalForm.new(invalid_form_params) }
    let(:pq)                  { DBHelpers.pqs.first }
    let(:form_params)         do
      {
        pq_id: pq.id,
        action_officer_id: [ao1.id, ao2.id]
      }
    end
  end

  describe 'propose' do
    include_context 'test_values'
    context 'when the supplied form data is not valid' do
      it 'raises an error' do
        expect do
          invalid_form = ProposalForm.new(invalid_form_params)
          ProposalService.new.propose(invalid_form)
        end.to raise_error(ArgumentError)
      end
    end
  end  
end
