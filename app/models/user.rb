# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default("")
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_type        :string
#  invited_by_id          :integer
#  invitations_count      :integer          default(0)
#  roles                  :string
#  deleted                :boolean          default(FALSE)
#  failed_attempts        :integer          default(0)
#  unlock_token           :string
#  locked_at              :datetime
#

class User < ApplicationRecord
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  ROLE_PQ_USER = "PQUSER".freeze
  ROLE_ADMIN = "ADMIN".freeze

  ROLES = [
    ROLE_PQ_USER,
    ROLE_ADMIN,
  ].freeze

  has_paper_trail

  devise :invitable,
         :database_authenticatable,
         :recoverable,
         :rememberable,
         :trackable,
         :lockable,
         :timeoutable,
         :validatable,
         validate_on_invite: true

  validates :name, presence: true
  validates :roles, presence: true

  after_initialize :set_defaults

  def invited_by_user
    invited_by_id && User.find(invited_by_id).name
  end

  def active_for_authentication?
    !deleted? && super
  end

  def set_defaults
    self.roles ||= ROLE_PQ_USER
  end

  def pq_user?
    roles.split(",").include?(ROLE_PQ_USER)
  end

  def admin?
    roles.split(",").include?(ROLE_ADMIN)
  end

  scope :active_list, -> { where("deleted = ? OR deleted = ? AND updated_at > ?", false, true, 2.days.ago) }
end
