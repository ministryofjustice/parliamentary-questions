require 'spec_helper'

describe ProposalForm, type: :model do
  describe 'validation error messages' do
    let(:form) { build(:proposal_form) }
    subject { form.errors.map(&:message) }

    before do
      form.valid?
    end

    context 'when pq_id is missing' do
      it { is_expected.to include('Please provide question id to proposal') }
    end

    context 'when action_officer_id is missing' do
      it { is_expected.to include('Please select at least one action officer') }
    end

    context 'when action_officer_id is empty' do
      let(:form) { build(:proposal_form, action_officer_id: ['']) }
      it { is_expected.to include('Please select at least one action officer') }
    end

    context 'when all required fields are provided' do
      let(:form) { build(:proposal_form, pq_id: 1, action_officer_id: [1]) }
      it { is_expected.to be_empty }
    end
  end
end
