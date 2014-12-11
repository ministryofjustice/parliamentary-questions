FactoryGirl.define do
  factory :minister, aliases: [:policy_minister] do
    name { Faker::Name.name }
    title { Faker::Name.title }
    deleted false

    factory :deleted_minister do
      deleted true
    end
  end
end
