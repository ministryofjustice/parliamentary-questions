# == Schema Information
#
# Table name: pqa_import_runs
#
#  id             :integer          not null, primary key
#  start_time     :datetime
#  end_time       :datetime
#  status         :string
#  num_created    :integer
#  num_updated    :integer
#  error_messages :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :pqa_import_run do
    start_time      { 120.seconds.ago }
    end_time        { 115.seconds.ago }
    status          { "OK" }
    num_created     { 6 }
    num_updated     { 1 }
    error_messages  { nil }
  end
end
