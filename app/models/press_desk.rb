class PressDesk < ActiveRecord::Base
  has_paper_trail
	validates :name, uniqueness: true, presence: true
	has_many :action_officers
	has_many :press_officers

	def email_output
		result = ""
		press_officers.each do |po|
			result << ";#{po.email}"
		end
		result
	end

  def active?
    !deleted?
  end
end
