class ActionOfficersPq < ActiveRecord::Base
  has_paper_trail
  belongs_to :pq
	belongs_to :action_officer

  def accept
    update(response: :accepted)
  end

  def reject(option, reason)
    update(response: :rejected, reason_option: option, reason: reason)
  end

  def reset
    update(response: :awaiting)
  end

  def rejected?
    response.to_sym == :rejected
  end

  def accepted?
    response.to_sym == :accepted
  end

  def response
    self[:response].to_sym
  end
end
