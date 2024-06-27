# == Schema Information
#
# Table name: action_officers
#
#  id                 :integer          not null, primary key
#  name               :string
#  email              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  deleted            :boolean          default(FALSE)
#  phone              :string
#  deputy_director_id :integer
#  press_desk_id      :integer
#  group_email        :string
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :action_officer do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    deputy_director
    press_desk
  end
end
