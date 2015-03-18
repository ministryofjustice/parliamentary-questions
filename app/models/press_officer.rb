class PressOfficer < ActiveRecord::Base
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  has_paper_trail
  validates_format_of :email,:with => Devise::email_regexp
  validates :press_desk_id, presence: true

  belongs_to :press_desk
end
