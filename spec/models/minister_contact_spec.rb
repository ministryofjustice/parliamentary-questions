require 'spec_helper'

describe MinisterContact do
  subject { build(:minister_contact) }

  it { should belong_to(:minister) }

  it { should validate_uniqueness_of(:email) }
  it { should allow_value(Faker::Internet.email).for(:email)}
  it { should_not allow_value('invalid').for(:email)}
end
