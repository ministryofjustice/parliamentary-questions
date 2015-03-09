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
