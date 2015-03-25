class Division < ActiveRecord::Base
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  has_paper_trail
  validates :name, presence: true
  validates :directorate_id, presence: true 
  has_many :deputy_directors
  belongs_to :directorate
end
