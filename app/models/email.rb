class Email < ActiveRecord::Base
  EMAIL_REGEXP     = /\A(.*<)?[^@\s]+@([^@\s]+\.)+[^@\s]+>?\z/
  EMAIL_DELIMITERS = [';', ':']

  validates :method, presence: true
  validates :from, presence: true
  validates :to, presence: true
  validates :reply_to, presence: true

  validates_format_of :from, :with => EMAIL_REGEXP
  validates_format_of :reply_to, :with => EMAIL_REGEXP

  validate :concatenated_email_to_format
  validate :concatenated_email_cc_format

  validates :mailer, inclusion: { in: %w(DbSyncMailer ImportMailer PqMailer) }
  validates :status, inclusion: { in: %w(new sending sent failed abandoned)  }

  serialize :params

  scope :new_only,  -> { where(status: 'new' ).order(:id)             }
  scope :waiting,   -> { where(status: ['new', 'failed']).order(:id)  }
  scope :abandoned, -> { where(status: 'abandoned' ).order(:id)       }

  private

  def concatenated_email_to_format
    unless concatenated_email_format(:to)
      errors.add(:to, 'invalid')
    end
  end

  def concatenated_email_cc_format
    unless concatenated_email_format(:cc)
      errors.add(:cc, 'invalid')
    end
  end

  def concatenated_email_format(field)
    return true unless attribute(field)

    EMAIL_DELIMITERS.any? do |delimiter|
      all_valid_emails?(attribute(field).split(delimiter))
    end
  end

  def all_valid_emails?(emails)
    emails.all?{ |email| email.strip =~ EMAIL_REGEXP } 
  end
end
