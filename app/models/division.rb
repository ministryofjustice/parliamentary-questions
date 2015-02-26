class Division < ActiveRecord::Base
  extend SoftDeletion
  has_paper_trail
  validates :directorate_id, presence: true

	has_many :deputy_directors
	belongs_to :directorate
end
