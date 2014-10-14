# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :action_officer do
    name { Faker::Name.name }
    email { Faker::Internet.safe_email }
    deputy_director
    press_desk
  end
end
