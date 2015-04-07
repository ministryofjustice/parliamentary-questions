# == Schema Information
#
# Table name: press_officers
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  email         :string(255)
#  press_desk_id :integer
#  deleted       :boolean          default(FALSE)
#  created_at    :datetime
#  updated_at    :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :press_officer do
    name { Faker::Name.name }
    email { Faker::Internet.safe_email }
    press_desk
  end
end
