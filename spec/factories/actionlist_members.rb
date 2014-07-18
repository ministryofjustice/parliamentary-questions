# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :actionlist_member do
    name "actionlist Member 1"
    email "member.one@actionlist.com"
    deleted false
  end
end
