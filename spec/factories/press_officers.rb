# == Schema Information
#
# Table name: press_officers
#
#  id            :integer          not null, primary key
#  name          :string
#  email         :string
#  press_desk_id :integer
#  deleted       :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :press_officer do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    press_desk
  end
end
