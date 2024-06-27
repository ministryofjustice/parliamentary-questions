# == Schema Information
#
# Table name: early_bird_organisers
#
#  id         :bigint           not null, primary key
#  date_from  :date
#  date_to    :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :early_bird_organiser do
    date_from { Time.zone.today + 5 }
    date_to { Time.zone.today + 10 }
  end
end
