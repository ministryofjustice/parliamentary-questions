require 'spec_helper'

describe GeckoReport do
  let(:gecko) { GeckoReport.new }

  it '#initialize - creates items for gecko' do
    expect(gecko).to be_an_instance_of GeckoReport
  end

end
