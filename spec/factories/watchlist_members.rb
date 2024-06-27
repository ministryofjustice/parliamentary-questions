# == Schema Information
#
# Table name: watchlist_members
#
#  id         :integer          not null, primary key
#  name       :string
#  email      :string
#  deleted    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :watchlist_member do
    name { "Watchlist Member 1" }
    email { "member.one@watchlist.com" }
    deleted { false }
  end
end
