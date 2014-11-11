class Ogd < ActiveRecord::Base
  has_paper_trail
  validates :name, presence: true
  validates :acronym, presence: true
  has_many :pqs

  after_initialize :init

  def init
    self.deleted ||= false
  end
end
