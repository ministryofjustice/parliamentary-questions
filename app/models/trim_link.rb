class TrimLink < ActiveRecord::Base
	validates :data, presence: true
	validates :pq_id, presence: true

	belongs_to :pq

	def display_name
		filename.sub! File.extname(filename),''
	end
end
