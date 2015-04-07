# == Schema Information
#
# Table name: minister_contacts
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  email       :string(255)
#  phone       :string(255)
#  minister_id :integer
#  deleted     :boolean          default(FALSE)
#

require 'spec_helper'

describe MinisterContact do
  subject { build(:minister_contact) }

  it { should belong_to(:minister) }

  it { should validate_uniqueness_of(:email) }
  it { should allow_value(Faker::Internet.email).for(:email)}
  it { should_not allow_value('invalid').for(:email)}
end
