# Read about factories at https://github.com/thoughtbot/factory_girl


FactoryBot.define do
  factory :early_bird_member do
    name { "Early Bird Member 1" }
    email { "member.one@earlybird.com" }
    deleted { false }
  end
end
