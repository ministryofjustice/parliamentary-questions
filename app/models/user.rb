class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable


  after_initialize :set_defaults

  def set_defaults
    self.roles ||= 'PQUSER'
  end

  def self.ROLE_PQ_USER
    'PQUSER'
  end

  def self.ROLE_FINANCE
    'FINANCE'
  end

end
