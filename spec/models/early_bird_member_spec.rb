require 'spec_helper'

describe EarlyBirdMember do
	let(:member) {build(:early_bird_member)}

	describe 'validation' do

		it 'should pass onfactory build' do
			expect(member).to be_valid
		end

		it 'should have a name' do
			member.name=nil
			expect(member).to be_invalid
		end

		it 'should have a unique email' do
			member = create(:early_bird_member, name: 'Early Bird Member 1', email: 'member.one@earlybird.com')
			duplicate = build(:early_bird_member, name: 'Early Bird Member 2', email: 'member.one@earlybird.com')
			expect(duplicate).to be_invalid
		end
	end
end