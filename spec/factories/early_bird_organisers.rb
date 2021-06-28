FactoryBot.define do
  factory :early_bird_organiser do
    date_from { Time.zone.today + 5 }
    date_to { Time.zone.today + 10 }
  end
end
