# == Schema Information
#
# Table name: watchlist_members
#
#  id         :integer          not null, primary key
#  name       :string
#  email      :string
#  deleted    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "spec_helper"

describe WatchlistMember do
  let(:member) { build(:watchlist_member) }

  describe "validation" do
    it "passes onfactory build" do
      expect(member).to be_valid
    end

    it "has a name" do
      member.name = nil
      expect(member).to be_invalid
    end

    it "has a unique email" do
      create(:watchlist_member, name: "Watchlist Member 1", email: "member.one@watchlist.com")
      duplicate = build(:watchlist_member, name: "Watchlist Member 2", email: "member.one@watchlist.com")
      expect(duplicate).to be_invalid
    end
  end
end
