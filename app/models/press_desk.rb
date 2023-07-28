# == Schema Information
#
# Table name: press_desks
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  deleted    :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

class PressDesk < ApplicationRecord
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  has_paper_trail
  validates :name, uniqueness: true, presence: true # rubocop:disable Rails/UniqueValidationWithoutIndex
  has_many :action_officers
  has_many :press_officers
  scope :active_list, -> { where("press_desks.deleted = ? OR press_desks.deleted = ? AND press_desks.updated_at > ?", false, true, 2.days.ago) }

  def press_officer_emails
    press_officers
      .reject(&:deleted?)
      .map(&:email)
      .reject(&:blank?)
  end
end
