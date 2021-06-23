FactoryBot.define do
  factory :early_bird_organiser do
    date_from { Date.new(2021, 5, 20) }
    date_to { Date.new(2021, 6, 20) }
  end
end
