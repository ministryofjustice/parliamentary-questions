class WatchlistMember < ActiveRecord::Base
  has_paper_trail
	validates :name, presence: true
	validates :email, presence: true, uniqueness: true, on: :create
  	validates_format_of :email,:with => Devise::email_regexp
  
	before_validation WhitespaceValidator.new
	after_initialize :init

    def init
      self.deleted  ||= false           #will set the default value only if it's nil
    end
end
