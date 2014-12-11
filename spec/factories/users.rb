# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    name 'User'
    email 'user@example.com'
    password '12345678'
    roles 'PQUSER'
  end
end
