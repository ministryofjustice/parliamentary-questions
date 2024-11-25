# == Schema Information
#
# Table name: early_bird_members
#
#  id         :integer          not null, primary key
#  name       :string
#  email      :string
#  deleted    :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :early_bird_member do
    name { "Early Bird Member 1" }
    sequence(:email) { |n| "member.one.#{n}@earlybird.com" }
    deleted { false }
  end
end
