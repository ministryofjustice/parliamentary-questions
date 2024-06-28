# == Schema Information
#
# Table name: press_officers
#
#  id            :integer          not null, primary key
#  name          :string
#  email         :string
#  press_desk_id :integer
#  deleted       :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class PressOfficer < ApplicationRecord
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  has_paper_trail
  validates :name, presence: true
  # validates_format_of :email, with: Devise.email_regexp
  validates :email, format: { with: Devise.email_regexp }
  validates :press_desk_id, presence: true
  belongs_to :press_desk
  scope :active_list, -> { where("deleted = ? OR deleted = ? AND updated_at > ?", false, true, 2.days.ago) }
end
