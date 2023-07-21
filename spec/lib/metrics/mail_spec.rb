require "spec_helper"

describe Metrics::Mail do
  subject(:mail) { described_class.new }

  let(:email) { instance_double Email }

  before do
    allow(Email).to receive(:waiting).and_return([email])
    allow(Email).to receive(:abandoned).and_return([])

    mail.collect!
  end

  it "#collect! - updates the email and token metrics" do
    expect(mail.num_waiting).to be 1
    expect(mail.num_abandoned).to be 0
  end

  describe "#email_error?" do
    it "returns false if abandoned/waiting emails within threshold" do
      expect(mail.email_error?).to be false
    end

    it "returns true if abandoned/waiting emails within threshold" do
      threshold = Settings.gecko_warning_levels.num_emails_waiting
      allow(mail).to receive(:num_waiting).and_return(threshold + 1) # rubocop:disable RSpec/SubjectStub

      expect(mail.email_error?).to be true
    end
  end

  describe "#token_error?" do
    it "returns false if answered tokens within threshold" do
      allow(Token)
        .to receive(:assignment_stats)
        .and_return(total: 6, ack: 6, open: 0, pctg: 100.00)
      mail.collect!

      expect(mail.token_error?).to be false
    end

    it "returns true if answered tokens outside threshold" do
      allow(Token)
        .to receive(:assignment_stats)
        .and_return(total: 6, ack: 2, open: 4, pctg: 33.33)
      mail.collect!

      expect(mail.token_error?).to be true
    end
  end
end
