# == Schema Information
#
# Table name: trim_links
#
#  id         :integer          not null, primary key
#  filename   :string
#  size       :integer
#  data       :binary
#  pq_id      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted    :boolean          default(FALSE)
#

class TrimLink < ApplicationRecord
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  attr_accessor :file

  after_initialize :extract_details

  has_paper_trail
  belongs_to :pq

  validate :trim_file_format
  validates :data, presence: true

private

  def trim_file_format
    errors.add(:file, "Invalid file selected!") if file && !::Validators::Trim.valid_upload?(file)
  end

  def extract_details
    return unless file

    self.filename = file.original_filename
    self.data = file.read
    self.size = data.size
  end
end
