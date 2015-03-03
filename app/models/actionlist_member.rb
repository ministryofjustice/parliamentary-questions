class ActionlistMember < ActiveRecord::Base
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  has_paper_trail
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, on: :create
  validates_format_of :email,:with => Devise::email_regexp

	before_validation Validators::Whitespace.new
end
