# == Schema Information
#
# Table name: directorates
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  deleted    :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :directorate do
    name { Faker::Company.name }
  end
end
