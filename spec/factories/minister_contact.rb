# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :minister_contact do
    name "contact name"
    email "mail.mail.com"
    phone ""
    deleted false
  end
end
