# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default("")
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  name                   :string(255)
#  invitation_token       :string(255)
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string(255)
#  invitations_count      :integer          default(0)
#  roles                  :string(255)
#  deleted                :boolean          default(FALSE)
#

class User < ActiveRecord::Base
  extend  SoftDeletion::Collection
  include SoftDeletion::Record

  ROLE_PQ_USER  = 'PQUSER'
  ROLE_FINANCE  = 'FINANCE'

  ROLES         = [
    ROLE_FINANCE,
    ROLE_PQ_USER
  ]

  has_paper_trail

  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :trackable,
         :validatable, :validate_on_invite => true

  validates :name, presence: true
  validates :roles, presence: true

  after_initialize :set_defaults

  def self.finance
    active.where(roles: ROLE_FINANCE)
  end

  def invited_by_user
    invited_by_id && User.find(invited_by_id).name
  end

  def active_for_authentication?
    !self.deleted? && super
  end

  def set_defaults
    self.roles ||= ROLE_PQ_USER
  end

  def pq_user?
    roles == ROLE_PQ_USER
  end

  def finance_user?
    roles == ROLE_FINANCE
  end
end
