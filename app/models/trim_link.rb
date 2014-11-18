class TrimLink < ActiveRecord::Base
  has_paper_trail

  belongs_to :pq

	validates :data, presence: true
  validates :filename, format: /\.tr5\z/

  def archive
    update(deleted: true)
  end

  def unarchive
    update(deleted: false)
  end
end
