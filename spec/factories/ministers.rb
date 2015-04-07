# == Schema Information
#
# Table name: ministers
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  title      :string(255)
#  deleted    :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#  member_id  :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :minister do
    name { Faker::Name.name }
    title { Faker::Name.title }
    deleted false

    factory :deleted_minister do
      deleted true
    end
  end
end
