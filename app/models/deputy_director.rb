class DeputyDirector < ActiveRecord::Base
  has_paper_trail
  validates :division_id, presence: true
  validates :email, presence: true

  has_many :action_officers
  belongs_to :division
end
