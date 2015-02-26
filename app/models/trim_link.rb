class TrimLink < ActiveRecord::Base
  extend SoftDeletion

  attr_accessor :file
  after_initialize :extract_details

  has_paper_trail
  belongs_to :pq

  validate :trim_file_format
  validates :data, presence: true

  def archive
    update(deleted: true)
  end

  def unarchive
    update(deleted: false)
  end

  private

  def trim_file_format
    if file && !::Trim::Validator.valid_upload?(file)
      errors.add(:file, 'Missing or invalid trim link file!')
    end
  end

  def extract_details
    return unless file
    self.filename = file.original_filename
    self.data = file.read
    self.size = data.size
  end
end
