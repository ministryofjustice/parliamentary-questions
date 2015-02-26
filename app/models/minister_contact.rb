class MinisterContact < ActiveRecord::Base
  extend SoftDeletion
  has_paper_trail
  validates :email, uniqueness: true, on: :create
  validates_format_of :email,:with => Devise::email_regexp

  belongs_to :minister
end
