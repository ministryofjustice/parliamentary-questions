# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :minister_contact do
    name { Faker::Lorem.word }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
    deleted false

    factory :deleted_minister_contact do
      deleted true
    end
  end
end
