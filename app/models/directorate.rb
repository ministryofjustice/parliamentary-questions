class Directorate < ActiveRecord::Base
  has_paper_trail
  has_many :divisions
  after_initialize :init

  def init
    self.deleted ||= false
  end

  def active?
    !deleted?
  end
end
