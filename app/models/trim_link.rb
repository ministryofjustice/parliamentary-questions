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

class TrimLink < ActiveRecord::Base
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
    if file && !::Validators::Trim.valid_upload?(file)
      errors.add(:file, 'Invalid file selected!')
    end
  end

  def extract_details
    return unless file
    self.filename = file.original_filename
    self.data = file.read
    self.size = data.size
  end
end
