# == Schema Information
#
# Table name: ogds
#
#  id         :integer          not null, primary key
#  name       :string
#  acronym    :string
#  deleted    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :ogd do
    name { "Ministry of Defence" }
    acronym { "MOD" }
  end
end
