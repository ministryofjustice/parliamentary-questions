class Ogd < ActiveRecord::Base
  validates :name, presence: true
  validates :acronym, presence: true
  has_many :pqs

  after_initialize :init

  def init
    self.deleted  ||= false           #will set the default value only if it's nil
  end
end
