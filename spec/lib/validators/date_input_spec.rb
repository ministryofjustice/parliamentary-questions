require 'spec_helper'

describe Validators::DateInput do
  
  include Validators::DateInput

  let(:window)  { Validators::DateInput::WINDOW  + 1.days }
  let(:max_len) { Validators::DateInput::MAX_LEN          }

  it 'should raise an error if the input is above the maximum size' do
    buffer = "1" *  (max_len + 1)

    expect { secure_parse(buffer) }.to raise_error(Validators::DateInput::DateTimeInputError)
  end

  it 'should raise an error if the input cannot be parsed as a date' do
    buffer = "\x90" *  (max_len + 1)

    expect { secure_parse(buffer) }.to raise_error(Validators::DateInput::DateTimeInputError)
  end

  it 'should raise an error if date is outside the expected window' do
    date_a = DateTime.now + window
    date_b = DateTime.now - window

    expect { secure_parse(date_a.to_s) }.to raise_error(Validators::DateInput::DateTimeInputError)
    expect { secure_parse(date_b.to_s) }.to raise_error(Validators::DateInput::DateTimeInputError)
  end

  it 'should return a date time if input is correct' do
    expect(secure_parse(Date.today.to_s)).to eq Date.today
  end

end