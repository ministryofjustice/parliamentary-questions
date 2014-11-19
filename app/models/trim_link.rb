class TrimLink < ActiveRecord::Base
  has_paper_trail

  belongs_to :pq

  attr_accessor :file

	validates :data, presence: true
  validates :filename, format: /\.tr5\z/

  after_initialize :extract_details

  def archive
    update(deleted: true)
  end

  def unarchive
    update(deleted: false)
  end

private

  def extract_details
    return unless file
    self.filename = file.original_filename
    self.data = file.read
    self.size = data.size
  end
end
