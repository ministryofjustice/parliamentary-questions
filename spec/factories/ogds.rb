# == Schema Information
#
# Table name: ogds
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  acronym    :string(255)
#  deleted    :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ogd do
    name "Ministry of Defence"
    acronym "MOD"
  end
end
