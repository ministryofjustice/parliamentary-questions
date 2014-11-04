class TrimLink < ActiveRecord::Base
  has_paper_trail
	validates :data, presence: true
	validates :pq_id, presence: true

	belongs_to :pq

	def display_name
		filename.sub! File.extname(filename),''
	end
end
