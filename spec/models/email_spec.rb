require 'spec_helper'

describe Email, :type => :model do
  let(:email)      { 'user@domain.com'  }
  let(:not_email)  { 'user@text'        }
  let(:mail)       { build(:pq_email)      }

  it 'should pass factory build' do
    expect(mail).to be_valid
  end

  it { should validate_inclusion_of(:mailer).in_array(%w(DbSyncMailer ImportMailer PqMailer)) }

  it { should validate_presence_of(:method) }

  it { should validate_presence_of(:from) }
  it { should allow_value(email).for(:from) }
  it { should_not allow_value(not_email).for(:from) }

  it { should validate_presence_of(:to) }
  it { should allow_value(email).for(:to) }
  it { should_not allow_value(not_email).for(:to) }

  it { should validate_presence_of(:cc) }
  it { should allow_value(email).for(:cc) }
  it { should_not allow_value(not_email).for(:cc) }
  
  it { should validate_presence_of(:reply_to) }
  it { should allow_value(email).for(:reply_to) }
  it { should_not allow_value(not_email).for(:reply_to) }

  it 'should have 0 send attempts by default' do
    expect(mail.num_send_attempts).to eq 0
  end

  it 'should have status set to new by default' do
    expect(mail.status).to eq 'new'
  end

  it { should validate_inclusion_of(:status).in_array(%w(new sending sent abandoned)) }

end
