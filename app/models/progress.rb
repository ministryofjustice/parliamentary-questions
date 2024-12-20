# == Schema Information
#
# Table name: progresses
#
#  id             :integer          not null, primary key
#  name           :string
#  progress_order :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Progress < ApplicationRecord
  def classname
    name.downcase.sub " ", "-"
  end

  def self.find_by_status(status)
    Progress.find_by(name: status)
  end

  def self.unassigned
    find_by(status: self.UNASSIGNED)
  end

  def self.no_response
    find_by(status: self.NO_RESPONSE)
  end

  def self.draft_pending
    find_by(status: self.DRAFT_PENDING)
  end

  def self.rejected
    find_by(status: self.REJECTED)
  end

  def self.with_pod
    find_by(status: self.WITH_POD)
  end

  def self.pod_cleared
    find_by(status: self.POD_CLEARED)
  end

  def self.with_minister
    find_by(status: self.WITH_MINISTER)
  end

  def self.minister_cleared
    find_by(status: self.MINISTER_CLEARED)
  end

  def self.transfer
    find_by(status: self.TRANSFER)
  end

  def self.answered
    find_by(status: self.ANSWERED)
  end

  def self.transferred_out
    find_by(status: self.TRANSFERRED_OUT)
  end

  # rubocop:disable Naming/MethodName

  def self.UNASSIGNED
    "Unassigned"
  end

  def self.NO_RESPONSE
    "No response"
  end

  def self.DRAFT_PENDING
    "Draft Pending"
  end

  def self.REJECTED
    "Rejected"
  end

  def self.WITH_POD
    "With POD"
  end

  def self.POD_CLEARED
    "POD Cleared"
  end

  def self.WITH_MINISTER
    "With Minister"
  end

  def self.MINISTER_CLEARED
    "Minister Cleared"
  end

  def self.ANSWERED
    "Answered"
  end

  def self.TRANSFERRED_OUT
    "Transferred out"
  end

  def self.TRANSFER
    "Transfer"
  end

  # rubocop:enable Naming/MethodName

  def self.new_questions
    [
      Progress.UNASSIGNED,
      Progress.NO_RESPONSE,
      Progress.REJECTED,
    ]
  end

  def self.in_progress_questions
    [
      Progress.DRAFT_PENDING,
      Progress.WITH_POD,
      Progress.POD_CLEARED,
      Progress.WITH_MINISTER,
      Progress.MINISTER_CLEARED,
    ]
  end

  def self.closed_questions
    [
      Progress.ANSWERED,
      Progress.TRANSFERRED_OUT,
    ]
  end

  def self.visible
    [new_questions, in_progress_questions].flatten
  end
end
