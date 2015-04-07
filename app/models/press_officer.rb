# == Schema Information
#
# Table name: press_officers
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  email         :string(255)
#  press_desk_id :integer
#  deleted       :boolean          default(FALSE)
#  created_at    :datetime
#  updated_at    :datetime
#

class PressOfficer < ActiveRecord::Base
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  has_paper_trail
  validates :name, presence: true
  validates_format_of :email,:with => Devise::email_regexp
  validates :press_desk_id, presence: true
  belongs_to :press_desk
end
