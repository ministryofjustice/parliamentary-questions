# == Schema Information
#
# Table name: press_desks
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  deleted    :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :press_desk do
    name { Faker::Lorem.sentence(2) }
  end
end
