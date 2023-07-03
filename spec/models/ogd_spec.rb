# == Schema Information
#
# Table name: ogds
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  acronym    :string(255)
#  deleted    :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

require "spec_helper"

describe Ogd do
  let(:ogd) { build(:ogd) }

  it "passes factory build" do
    expect(ogd).to be_valid
  end

  it "has a name" do
    ogd.name = nil
    expect(ogd).to be_invalid
  end

  it "has an Acronym" do
    ogd.acronym = nil
    expect(ogd).to be_invalid
  end
end
