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

require "rails_helper"

describe Email, type: :model do
  let(:email)       { "user@domain.com"                     }
  let(:emails)      { "user1@domain.com; user2@domain.com"  }
  let(:named_email) { "A User <user@domain.com>"            }
  let(:not_email)   { "user@text"                           }
  let(:mail)        { build(:pq_email)                      }

  it "passes factory build" do
    expect(mail).to be_valid
  end

  it { is_expected.to validate_inclusion_of(:mailer).in_array(%w[DbSyncMailer ImportMailer PqMailer]) }

  it { is_expected.to validate_presence_of(:method) }

  it { is_expected.to validate_presence_of(:from) }
  it { is_expected.to allow_value(email).for(:from) }
  it { is_expected.to allow_value(named_email).for(:from) }
  it { is_expected.not_to allow_value(not_email).for(:from) }
  it { is_expected.not_to allow_value(emails).for(:from) }

  it { is_expected.to validate_presence_of(:to) }
  it { is_expected.to allow_value(email).for(:to) }
  it { is_expected.to allow_value(named_email).for(:to) }
  it { is_expected.to allow_value(emails).for(:to) }
  # it { should_not allow_value(not_email).for(:to) }

  it { is_expected.to allow_value(email).for(:cc) }
  it { is_expected.to allow_value(nil).for(:cc) }
  it { is_expected.to allow_value(named_email).for(:cc) }
  it { is_expected.to allow_value(emails).for(:cc) }
  # it { should_not allow_value(not_email).for(:cc) }

  it { is_expected.to validate_presence_of(:reply_to) }
  it { is_expected.to allow_value(email).for(:reply_to) }
  it { is_expected.to allow_value(named_email).for(:reply_to) }
  it { is_expected.not_to allow_value(emails).for(:reply_to) }
  it { is_expected.not_to allow_value(not_email).for(:reply_to) }

  it "has 0 send attempts by default" do
    expect(mail.num_send_attempts).to eq 0
  end

  it "has status set to new by default" do
    expect(mail.status).to eq "new"
  end

  it { is_expected.to validate_inclusion_of(:status).in_array(%w[new sending sent failed abandoned]) }
end
