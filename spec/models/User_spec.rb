require 'spec_helper'

describe User do
  let(:user) {build(:user)}

  it 'should pass factory build' do
    expect(user).to be_valid
  end

  it 'should provide a method for authentication' do
    expect(user.active_for_authentication?).to eql(true)
  end

  describe 'validations' do
    it 'should require a name' do
      user.name = nil
      expect(user).to be_invalid
    end

    it 'should require an email' do
      user.email = nil
      expect(user).to be_invalid
    end

    it 'should require a valid email' do
      user.email = 'colin'
      expect(user).to be_invalid
    end

    it 'should require a role' do
      user.roles = nil
      expect(user).to be_invalid
    end
  end
end
