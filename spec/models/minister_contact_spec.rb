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

require "spec_helper"

describe MinisterContact do
  subject { build(:minister_contact) }

  it { is_expected.to belong_to(:minister) }

  it { is_expected.to validate_uniqueness_of(:email) }
  it { is_expected.to allow_value(Faker::Internet.email).for(:email) }
  it { is_expected.not_to allow_value("invalid").for(:email) }
end
