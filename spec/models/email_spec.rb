# == Schema Information
#
# Table name: emails
#
#  id                :integer          not null, primary key
#  mailer            :string(255)
#  method            :string(255)
#  params            :text
#  from              :text
#  to                :text
#  cc                :text
#  reply_to          :text
#  send_attempted_at :datetime
#  sent_at           :datetime
#  num_send_attempts :integer          default(0)
#  status            :string(255)      default("new")
#  created_at        :datetime
#  updated_at        :datetime
#

require 'spec_helper'

describe Email, :type => :model do
  let(:email)       { 'user@domain.com'                     }
  let(:emails)      { 'user1@domain.com; user2@domain.com'  }
  let(:named_email) { 'A User <user@domain.com>'            }
  let(:not_email)   { 'user@text'                           }
  let(:mail)        { build(:pq_email)                      }

  it 'should pass factory build' do
    expect(mail).to be_valid
  end

  it { should validate_inclusion_of(:mailer).in_array(%w(DbSyncMailer ImportMailer PqMailer)) }

  it { should validate_presence_of(:method) }

  it { should validate_presence_of(:from) }
  it { should allow_value(email).for(:from) }
  it { should allow_value(named_email).for(:from) }
  it { should_not allow_value(not_email).for(:from) }
  it { should_not allow_value(emails).for(:from) }

  it { should validate_presence_of(:to) }
  it { should allow_value(email).for(:to) }
  it { should allow_value(named_email).for(:to) }
  it { should allow_value(emails).for(:to) }
  it { should_not allow_value(not_email).for(:to) }

  it { should allow_value(email).for(:cc) }
  it { should allow_value(nil).for(:cc) }
  it { should allow_value(named_email).for(:cc) }
  it { should allow_value(emails).for(:cc) }
  it { should_not allow_value(not_email).for(:cc) }
  
  it { should validate_presence_of(:reply_to) }
  it { should allow_value(email).for(:reply_to) }
  it { should allow_value(named_email).for(:reply_to) }
  it { should_not allow_value(emails).for(:reply_to) }
  it { should_not allow_value(not_email).for(:reply_to) }

  it 'should have 0 send attempts by default' do
    expect(mail.num_send_attempts).to eq 0
  end

  it 'should have status set to new by default' do
    expect(mail.status).to eq 'new'
  end

  it { should validate_inclusion_of(:status).in_array(%w(new sending sent failed abandoned)) }
end
