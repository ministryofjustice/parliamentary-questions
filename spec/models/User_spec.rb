# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default("")
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  name                   :string(255)
#  invitation_token       :string(255)
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string(255)
#  invitations_count      :integer          default(0)
#  roles                  :string(255)
#  deleted                :boolean          default(FALSE)
#  failed_attempts        :integer          default(0)
#  unlock_token           :string(255)
#  locked_at              :datetime
#

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
