# == Schema Information
#
# Table name: watchlist_members
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  deleted    :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe WatchlistMember do
	let(:member) {build(:watchlist_member)}

	describe 'validation' do

		it 'should pass onfactory build' do
			expect(member).to be_valid
		end

		it 'should have a name' do
			member.name=nil
			expect(member).to be_invalid
		end

		it 'should have a unique email' do
			member = create(:watchlist_member, name: 'Watchlist Member 1', email: 'member.one@watchlist.com')
			duplicate = build(:watchlist_member, name: 'Watchlist Member 2', email: 'member.one@watchlist.com')
			expect(duplicate).to be_invalid
		end
	end
end
