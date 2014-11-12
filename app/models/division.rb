class Division < ActiveRecord::Base
  has_paper_trail
  validates :directorate_id, presence: true

	has_many :deputy_directors
	belongs_to :directorate
  after_initialize :init

  def init
    self.deleted ||= false
  end

  def active?
    !deleted?
  end
end
