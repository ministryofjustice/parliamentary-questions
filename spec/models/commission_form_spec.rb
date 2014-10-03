require 'spec_helper'

describe CommissionForm, type: :model do
  describe 'validation error messages' do
    let(:form) { build(:commission_form)}
    subject { form.errors.values.flatten }
    before do
      form.valid?
    end

    context 'when minister_id is missing' do
      it { should include('Please select answering minister')}
    end

    context 'when action_officer_id is missing' do
      it { should include('Please select at least one action officer')}
    end

    context 'when action_officer_id is empty' do
      let(:form) { build(:commission_form, action_officer_id: [''])}
      it { should include('Please select at least one action officer')}
    end

    context 'when date_for_answer id empty' do
      it { should include('Please choose date for answer')}
    end

    context 'when internal_deadline id empty' do
      it { should include('Please choose internal deadline')}
    end

    context 'when all required fields are provided' do
      let(:form) { build(:commission_form, minister_id: 1, action_officer_id: [1], date_for_answer: '20/10/2014', internal_deadline: '14/10/2014')}
      it { should be_empty }
    end
  end
end