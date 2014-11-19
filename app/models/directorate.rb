class Directorate < ActiveRecord::Base
  has_paper_trail
  has_many :divisions
end
