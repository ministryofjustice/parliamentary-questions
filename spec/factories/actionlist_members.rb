# == Schema Information
#
# Table name: actionlist_members
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  deleted    :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :actionlist_member do
    name "actionlist Member 1"
    email "member.one@actionlist.com"
    deleted false
  end
end
