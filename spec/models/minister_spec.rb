require 'spec_helper'

describe Minister do
	let(:minister) {build(:minister)}

	it 'should pass factory build' do
		expect(minister).to be_valid
	end

	describe "associations" do
		it 'should have a collection of PQs' do
			@pqs = minister.should respond_to(:pqs)
		end
	end
end
