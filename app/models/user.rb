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
