# == Schema Information
#
# Table name: trim_links
#
#  id         :integer          not null, primary key
#  filename   :string(255)
#  size       :integer
#  data       :binary
#  pq_id      :integer
#  created_at :datetime
#  updated_at :datetime
#  deleted    :boolean          default(FALSE)
#

require 'spec_helper'

describe TrimLink do
  it { is_expected.to belong_to :pq }
  it { is_expected.to validate_presence_of :data }
  it { is_expected.to allow_value('filename.tr5').for :filename }

  describe '#after_initialize' do
    subject { described_class.new file: double(original_filename: 'filename.tr5', read: 'data') }
    it { expect(subject.filename).to eq 'filename.tr5' }
    it { expect(subject.data).to eq 'data' }
  end
end
