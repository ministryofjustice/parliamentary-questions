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

class PressDesk < ActiveRecord::Base
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  has_paper_trail
  validates :name, uniqueness: true, presence: true
  has_many :action_officers
  has_many :press_officers

  def press_officer_emails
    press_officers
      .map(&:email)
      .reject(&:blank?)
  end
end
