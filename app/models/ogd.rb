class Ogd < ActiveRecord::Base
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  has_paper_trail
  validates :name, presence: true
  validates :acronym, presence: true
  has_many :pqs

  def self.by_name(name)
    where("name ILIKE :search OR acronym ILIKE :search", search: "%#{name.strip}%")
  end
end
