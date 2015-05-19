# == Schema Information
#
# Table name: tokens
#
#  id           :integer          not null, primary key
#  path         :string(255)
#  token_digest :string(255)
#  expire       :datetime
#  entity       :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  acknowledged :string(255)
#  ack_time     :datetime
#


FactoryGirl.define do
  factory :token do
    
    sequence(:path)       { |n|  "assignment/uin-#{n}" }
    token_digest          '26786dad0ec06ec44e09a9a486f574142898c948c9cbc2469dda816dbba7d3c3'
    expire                '2015-05-22 22:59:59'
    sequence(:entity)     { |n|  "assignment:#{n}" }

  end
end


