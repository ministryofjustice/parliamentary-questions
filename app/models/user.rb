class User < ActiveRecord::Base
  has_paper_trail

  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :trackable,
         :validatable, :validate_on_invite => true

  validates :name, presence: true
  validates :roles, presence: true

  after_initialize :set_defaults

  def invited_by_user
    User.find(self.invited_by_id).name unless invited_by_id.nil?
  end

  def active_for_authentication?
    super and self.is_active!=false
  end

  def set_defaults
    self.roles ||= User.ROLE_PQ_USER
  end

  def self.ROLE_PQ_USER
    'PQUSER'
  end

  def self.ROLE_FINANCE
    'FINANCE'
  end

  def is_pq_user?
    roles == User.ROLE_PQ_USER
  end

  def is_finance_user?
    roles == User.ROLE_FINANCE
  end

  def active?
    is_active?
  end
end
