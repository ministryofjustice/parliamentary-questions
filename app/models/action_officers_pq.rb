class ActionOfficersPq < ActiveRecord::Base
  belongs_to :pq
	belongs_to :action_officer

  def answered
    return reject || accept
  end

  def self.rejected()
    where('reject = ?', true)
  end

  def self.accepted()
    where('accept = ?', true)
  end

end