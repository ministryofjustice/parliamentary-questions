require 'spec_helper'

describe Metrics::Mail do
  let(:email) { double Email }

  before(:each) do
    allow(Email).to receive(:waiting).and_return([email])
    allow(Email).to receive(:abandoned).and_return([])

    subject.collect!
  end 

  it '#collect! - updates the email and token metrics' do
    expect(subject.num_waiting).to be 1
    expect(subject.num_abandoned).to be 0
  end

  context '#email_error?' do
    it 'returns false if abandoned/waiting emails within threshold' do
      expect(subject.email_error?).to be false
    end

    it 'returns true if abandoned/waiting emails within threshold' do
      threshold = Settings.gecko_warning_levels.num_emails_waiting 
      allow(subject).to receive(:num_waiting).and_return(threshold + 1)

      expect(subject.email_error?).to be true
    end
  end

  context '#token_error?' do
    it 'returns false if answered tokens within threshold' do
      allow(Token)
        .to receive(:assignment_stats)
        .and_return({ total: 6, ack: 6, open: 0, pctg: 100.00 })
      subject.collect!

      expect(subject.token_error?).to be false
    end

    it 'returns true if answered tokens outside threshold' do
      allow(Token)
        .to receive(:assignment_stats)
        .and_return({ total: 6, ack: 2, open: 4, pctg: 33.33 })
      subject.collect!

      expect(subject.token_error?).to be true
    end
  end
end