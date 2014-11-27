require 'spec_helper'

describe ActionOfficersPq do
  subject { described_class.new pq: create(:pq), action_officer: create(:action_officer) }
  describe 'relationships' do
    it { is_expected.to belong_to :pq }
    it { is_expected.to belong_to :action_officer }
  end

  describe '#accept' do
    before { subject.accept }
    it { is_expected.to be_accepted }
  end

  describe '#reject' do
    before { subject.reject('option', 'reason') }

    it { is_expected.to be_rejected }

    it 'sets reason option' do
      expect(subject.reason_option).to eq 'option'
    end

    it 'sets reason' do
      expect(subject.reason).to eq 'reason'
    end
  end

  describe '#reset' do
    before do
      subject.response = :accepted;
      subject.reset
    end

    it 'marks as awaiting' do
      expect(subject.reload.response).to eq :awaiting
    end
  end

  describe '#rejected?' do
    it 'returns true when rejected' do

    end

    it 'returns false when not rejected' do

    end
  end

  describe '#accepted?' do
    it 'returns true when accepted' do

    end

    it 'returns false when not accepted' do

    end
  end
end
