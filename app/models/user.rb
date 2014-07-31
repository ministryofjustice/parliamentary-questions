class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable


  after_initialize :set_defaults

  def invited_by_user
    User.find(self.invited_by_id).name unless invited_by_id.nil?
  end

  #this method is called by devise to check for "active" state of the model
  def active_for_authentication?
    #remember to call the super
    #then put our own check to determine "active" state using
    #our own "is_active" column
    super and self.is_active?
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

end
