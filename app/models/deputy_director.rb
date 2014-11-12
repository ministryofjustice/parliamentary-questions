class DeputyDirector < ActiveRecord::Base
  has_paper_trail
	validates :division_id, presence: true

	has_many :action_officers
	belongs_to :division
  after_initialize :init

  def init
    self.deleted  ||= false
  end

  def active?
    !deleted?
  end
end
