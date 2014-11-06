require 'spec_helper'

describe TrimLink do
	let(:trim) {build(:trim_link)}

	it 'should pass factory build' do
		expect(trim).to be_valid
	end

	it 'should have binary data' do
		trim.data = nil
		expect(trim).to be_invalid
	end

	it 'should be linked to a pq' do
		trim.pq_id = nil
		expect(trim).to be_invalid
	end

  describe "associations" do
		it { is_expected.to belong_to :pq }
	end
end
