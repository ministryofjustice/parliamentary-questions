# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :press_desk do
    name { Faker::Lorem.sentence(2) }
  end
end
