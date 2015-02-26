class Directorate < ActiveRecord::Base
  extend SoftDeletion

  has_paper_trail
  has_many :divisions
end
