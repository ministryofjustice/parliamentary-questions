require 'spec_helper'

describe TrimLink do
  it { is_expected.to belong_to :pq }
  it { is_expected.to validate_presence_of :data }
  it { is_expected.to allow_value('filename.tr5').for :filename }
  it { is_expected.not_to allow_value('filename').for :filename }

  describe '#after_initialize' do
    subject { described_class.new file: double(original_filename: 'filename.tr5', read: 'data') }
    it { expect(subject.filename).to eq 'filename.tr5' }
    it { expect(subject.data).to eq 'data' }
  end

  describe '#archive' do
    it 'marks trim link as deleted' do
      subject = build(:trim_link)
      subject.archive
      expect(subject).to be_deleted
    end
  end

  describe '#unarchive' do
    it 'removes deleted flag from trim link' do
      subject = build(:trim_link, deleted: true)
      subject.unarchive
      expect(subject).not_to be_deleted
    end
  end
end
