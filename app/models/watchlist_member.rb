class WatchlistMember < ActiveRecord::Base
  has_paper_trail
	validates :name, presence: true
	validates :email, presence: true, uniqueness: true, on: :create
  validates_format_of :email,:with => Devise::email_regexp

	before_validation Validators::Whitespace.new
end
