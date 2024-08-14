# == Schema Information
#
# Table name: archives
#
#  id         :bigint           not null, primary key
#  prefix     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :archive do
    sequence(:prefix, "a")
  end
end
