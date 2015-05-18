require 'spec_helper'

describe GeckoCollection do

  it 'should iterate through the GeckoStatus objects in the expected order' do
    component_names = []
    gc = GeckoCollection.new
    gc.each do |status| 
      component_names << status.component_name
    end
    expect(component_names).to eq ['Database', 'Sendgrid', 'PQA API', 'Email', 'PQ Import', 'Smoke Tests']
  end

end


