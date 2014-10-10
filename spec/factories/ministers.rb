# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :minister do
    name { Faker::Name.name }
    title { Faker::Name.title }
    deleted false

    factory :deleted_minister do
      deleted true
    end
  end
end
