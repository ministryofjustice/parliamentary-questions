# == Schema Information
#
# Table name: directorates
#
#  id         :integer          not null, primary key
#  name       :string
#  deleted    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :directorate do
    name { Faker::Company.name }
  end
end
