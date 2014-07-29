class MinisterContact < ActiveRecord::Base
  validates :email, uniqueness: true, on: :create
  validates_format_of :email,:with => Devise::email_regexp

  belongs_to :minister
end