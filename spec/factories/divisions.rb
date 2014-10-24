# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :division do
    name { Faker::Commerce.department(1) }
    directorate
  end
end
