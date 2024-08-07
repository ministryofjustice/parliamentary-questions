# == Schema Information
#
# Table name: early_bird_members
#
#  id         :integer          not null, primary key
#  name       :string
#  email      :string
#  deleted    :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

describe EarlyBirdMember do
  let(:member) { build(:early_bird_member) }

  describe "validation" do
    it "passes onfactory build" do
      expect(member).to be_valid
    end

    it "has a name" do
      member.name = nil
      expect(member).to be_invalid
    end

    it "has a unique email" do
      create(:early_bird_member, name: "Early Bird Member 1", email: "member.one@earlybird.com")
      duplicate = build(:early_bird_member, name: "Early Bird Member 2", email: "member.one@earlybird.com")
      expect(duplicate).to be_invalid
    end
  end
end
