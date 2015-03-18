class DeputyDirector < ActiveRecord::Base
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  has_paper_trail
  validates :division_id, presence: true
  validates :email, presence: true

  has_many :action_officers
  belongs_to :division
end
