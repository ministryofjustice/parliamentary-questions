class Email < ActiveRecord::Base
  validates :method, presence: true
  validates :from, presence: true
  validates :to, presence: true
  validates :cc, presence: true
  validates :reply_to, presence: true

  validates_format_of :from, :with => Devise::email_regexp
  validates_format_of :to, :with => Devise::email_regexp
  validates_format_of :cc, :with => Devise::email_regexp
  validates_format_of :reply_to, :with => Devise::email_regexp

  validates :mailer, inclusion: { in: %w(DbSyncMailer ImportMailer PqMailer) }
  validates :status, inclusion: { in: %w(new sending sent abandoned)         }
end
