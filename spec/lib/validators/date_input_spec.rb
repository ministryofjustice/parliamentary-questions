require 'spec_helper'

describe Validators::DateInput do
  
  include Validators::DateInput

  let(:window)  { Validators::DateInput::WINDOW  + 1.days }
  let(:max_len) { Validators::DateInput::MAX_LEN          }

  it 'should raise an error if the input is above the maximum size' do
    buffer = "1" *  (max_len + 1)

    expect { parse_date(buffer) }.to raise_error(Validators::DateInput::DateTimeInputError)
  end

  it 'should raise an error if the input cannot be parsed as a date' do
    buffer = "\x90" *  (max_len + 1)

    expect { parse_date(buffer) }.to raise_error(Validators::DateInput::DateTimeInputError)
  end

  it 'should raise an error if date is outside the expected window' do
    date_a = DateTime.now + window
    date_b = DateTime.now - window

    expect { parse_datetime(date_a.to_s) }.to raise_error(Validators::DateInput::DateTimeInputError)
    expect { parse_datetime(date_b.to_s) }.to raise_error(Validators::DateInput::DateTimeInputError)
  end

  context '#parse_datetime' do
    it 'should return a date time if input is correct' do
      dt = DateTime.now.midnight
      expect(parse_datetime(dt.to_s)).to be_an_instance_of DateTime
      expect(parse_datetime(dt.to_s)).to eq dt
    end
  end

  context '#parse_date' do
    it 'should return a date if input is correct' do
      d = Date.today
      expect(parse_date(d.to_s)).to be_an_instance_of Date
      expect(parse_date(d.to_s)).to eq d
    end
  end
end