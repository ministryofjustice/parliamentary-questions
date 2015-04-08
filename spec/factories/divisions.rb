# == Schema Information
#
# Table name: divisions
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  directorate_id :integer
#  deleted        :boolean          default(FALSE)
#  created_at     :datetime
#  updated_at     :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :division do
    name { Faker::Commerce.department(1) }
    directorate
  end
end
