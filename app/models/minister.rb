class Minister < ActiveRecord::Base
  validates :email, uniqueness: true, on: :create
  validates_format_of :email,:with => Devise::email_regexp
  before_validation :strip_whitespace

  has_many :pqs
  has_many :minister_contacts
  accepts_nested_attributes_for :minister_contacts,
                                :allow_destroy => true,
                                :reject_if     => :all_blank

  def strip_whitespace
    self.name = self.name.strip unless self.name.nil?
    self.email = self.email.strip unless self.email.nil?
  end

  def self.all_active
    Minister.where(deleted: false).all
  end

end
