# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :press_officer do
    name { Faker::Name.name }
    email { Faker::Internet.safe_email }
    press_desk
  end
end
