class ActionOfficersPq < ActiveRecord::Base
  belongs_to :pq
	belongs_to :action_officer


  def self.rejected()
    where('reject = ?', true)
  end
end