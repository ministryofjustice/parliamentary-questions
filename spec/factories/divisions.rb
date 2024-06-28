# == Schema Information
#
# Table name: divisions
#
#  id             :integer          not null, primary key
#  name           :string
#  directorate_id :integer
#  deleted        :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :division do
    name { Faker::Commerce.department(max: 1) }
    directorate
  end
end
