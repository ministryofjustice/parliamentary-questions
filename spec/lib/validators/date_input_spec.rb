require "rails_helper"

describe Validators::DateInput do
  include described_class

  let(:window)  { Validators::DateInput::WINDOW + 1.day }
  let(:max_len) { Validators::DateInput::MAX_LEN }

  it "raises an error if the input is above the maximum size" do
    buffer = "1" * (max_len + 1)

    expect { parse_date(buffer) }.to raise_error(Validators::DateInput::DateTimeInputError)
  end

  it "raises an error if the input cannot be parsed as a date" do
    buffer = "\x90" * (max_len - 1)

    expect { parse_date(buffer) }.to raise_error(Validators::DateInput::DateTimeInputError)
  end

  it "raises an error if date is outside the expected window" do
    date_a = Time.zone.now + window
    date_b = Time.zone.now - window

    expect { parse_datetime(date_a.to_s) }.to raise_error(Validators::DateInput::DateTimeInputError)
    expect { parse_datetime(date_b.to_s) }.to raise_error(Validators::DateInput::DateTimeInputError)
  end

  it "raises an error if the time is outside the expected window" do
    date_s = "13/03/2015     25:15"

    expect { parse_datetime(date_s) }.to raise_error(Validators::DateInput::DateTimeInputError)
  end

  describe "#parse_datetime" do
    it "returns a date time if input is correct" do
      dt_with_gmt_adjust = Time.zone.now.midnight
      dt = Time.zone.parse(dt_with_gmt_adjust.strftime("%a, %d %b %Y %H:%M:%S"))
      expect(parse_datetime(dt.to_s)).to eq dt
    end
  end

  describe "#parse_date" do
    it "returns a date if input is correct" do
      d = Time.zone.today
      expect(parse_date(d.to_s)).to eq d
    end
  end
end
