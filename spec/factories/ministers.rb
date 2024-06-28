# == Schema Information
#
# Table name: ministers
#
#  id         :integer          not null, primary key
#  name       :string
#  title      :string
#  deleted    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  member_id  :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :minister do
    name { Faker::Name.name }
    title { Faker::Job.title }
    deleted { false }

    factory :deleted_minister do
      deleted { true }
    end
  end
end
