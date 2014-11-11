class ActionOfficersPq < ActiveRecord::Base
  has_paper_trail
  belongs_to :pq
	belongs_to :action_officer

  def answered
    reject || accept
  end

  scope :rejected, ->{ where(reject: true) }
  scope :accepted, ->{ where(accept: true) }
end
