# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :deputy_director do
    name { Faker::Name.name }
    email { Faker::Internet.safe_email }
    division
  end
end
