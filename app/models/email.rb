# == Schema Information
#
# Table name: emails
#
#  id                :integer          not null, primary key
#  mailer            :string
#  method            :string
#  params            :text
#  from              :text
#  to                :text
#  cc                :text
#  reply_to          :text
#  send_attempted_at :datetime
#  sent_at           :datetime
#  num_send_attempts :integer          default(0)
#  status            :string           default("new")
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Email < ApplicationRecord
  EMAIL_REGEXP     = /\A(.*<)?[^@\s]+@([^@\s]+\.)+[^@\s]+>?\z/
  EMAIL_DELIMITERS = [";", ":"].freeze

  validates :method, presence: true
  validates :from, presence: true
  validates :to, presence: true
  validates :reply_to, presence: true

  # validates_format_of :from, with: EMAIL_REGEXP
  # validates_format_of :reply_to, with: EMAIL_REGEXP
  validates :from, format: { with: EMAIL_REGEXP, format: true }
  validates :reply_to, format: { with: EMAIL_REGEXP, format: true }

  validate :concatenated_email_to_format
  validate :concatenated_email_cc_format

  validates :mailer, inclusion: { in: %w[DbSyncMailer ImportMailer PqMailer] }
  validates :status, inclusion: { in: %w[new sending sent failed abandoned]  }

  serialize :params

  scope :new_only,  -> { where(status: "new").order(:id) }
  scope :waiting,   -> { where(status: %w[new failed]).order(:id) }
  scope :abandoned, -> { where(status: "abandoned").order(:id) }

private

  def concatenated_email_to_format
    errors.add(:to, "invalid") unless concatenated_email_format(:to)
  end

  def concatenated_email_cc_format
    errors.add(:cc, "invalid") unless concatenated_email_format(:cc)
  end

  def concatenated_email_format(field)
    return true unless attribute(field)

    EMAIL_DELIMITERS.any? do |delimiter|
      all_valid_emails?(attribute(field).split(delimiter))
    end
  end

  def all_valid_emails?(emails)
    emails.all? { |email| email.strip =~ EMAIL_REGEXP }
  end
end
