require 'spec_helper'

describe Parli::XMLDecoder do
  let(:xml) {
    filepath = File.expand_path('../../fixtures/members.xml', __dir__)
    File.read(filepath)
  }
  describe "#decode_member" do
    it "returns a parli member instance" do
      member = Parli::XMLDecoder.decode_members(xml).first
      expect(member.member_id).to eq('172')
      expect(member.display_as).to eq('Ms Diane Abbott')
    end
  end
end
