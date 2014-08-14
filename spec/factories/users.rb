# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    name 'user one'
    email 'user.one@admin.com'
    password '123456789'
    roles 'PQUSER'
    is_active true
  end
end
