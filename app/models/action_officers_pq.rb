# == Schema Information
#
# Table name: action_officers_pqs
#
#  id                :integer          not null, primary key
#  pq_id             :integer          not null
#  action_officer_id :integer          not null
#  reason            :text
#  reason_option     :string(255)
#  updated_at        :datetime
#  created_at        :datetime
#  reminder_accept   :integer          default(0)
#  reminder_draft    :integer          default(0)
#  response          :string(255)      default("awaiting")
#

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
    response == :rejected
  end

  def accepted?
    response == :accepted
  end

  def awaiting_response?
    response == :awaiting
  end

  def response
    self[:response].to_sym
  end
end
