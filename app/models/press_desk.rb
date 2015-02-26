class PressDesk < ActiveRecord::Base
  extend SoftDeletion

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
