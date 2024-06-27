# == Schema Information
#
# Table name: action_officers
#
#  id                 :integer          not null, primary key
#  name               :string
#  email              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  deleted            :boolean          default(FALSE)
#  phone              :string
#  deputy_director_id :integer
#  press_desk_id      :integer
#  group_email        :string
#

class ActionOfficer < ApplicationRecord
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  has_paper_trail
  validates :name, presence: true
  # validates_format_of :email, with: Devise.email_regexp
  # validates_format_of :group_email, with: Devise.email_regexp, allow_blank: true
  validates :email, format: { with: Devise.email_regexp }
  validates :group_email, format: { with: Devise.email_regexp, allow_blank: true }
  validates :deputy_director_id, presence: true
  validates :press_desk_id, presence: true
  validates :email,
            uniqueness: {
              scope: :deputy_director_id,
              message: "an action officer cannot be assigned twice to the same deputy director",
            }

  has_many :action_officers_pqs
  has_many :pqs, through: :action_officers_pqs

  belongs_to :deputy_director
  belongs_to :press_desk

  before_validation Validators::Whitespace.new

  def self.by_name(name)
    active.where("name ILIKE ?", "%#{name}%")
  end

  def name_with_div
    if deputy_director.nil?
      name
    else
      "#{name} (#{deputy_director.division.name})"
    end
  end
  scope :inactive_list, -> { where("action_officers.deleted = ?", true) }
  scope :active_list, -> { where("action_officers.deleted = ? OR action_officers.deleted = ? AND action_officers.updated_at > ?", false, true, 2.days.ago) }
end
