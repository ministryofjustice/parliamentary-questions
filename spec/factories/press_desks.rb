# == Schema Information
#
# Table name: press_desks
#
#  id         :integer          not null, primary key
#  name       :string
#  deleted    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :press_desk do
    sequence(:name) { |n| "#{Faker::Lorem.sentence(word_count: 2)}#{n}" }
  end
end
