class Ogd < ActiveRecord::Base
  has_paper_trail
  validates :name, presence: true
  validates :acronym, presence: true
  has_many :pqs
end
