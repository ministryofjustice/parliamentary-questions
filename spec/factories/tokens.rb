# == Schema Information
#
# Table name: tokens
#
#  id           :integer          not null, primary key
#  path         :string
#  token_digest :string
#  expire       :datetime
#  entity       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  acknowledged :string
#  ack_time     :datetime
#

FactoryBot.define do
  factory :token do
    sequence(:path)       { |n| "assignment/uin-#{n}" }
    token_digest          { "26786dad0ec06ec44e09a9a486f574142898c948c9cbc2469dda816dbba7d3c3" }
    expire                { "2015-05-22 22:59:59" }
    sequence(:entity)     { |n| "assignment:#{n}" }
  end
end
