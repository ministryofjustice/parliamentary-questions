# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :Pq do
    uin { Faker::Lorem.characters(10) }
    house_id 1
    raising_member_id 1
    tabled_date "2014-05-08 13:45:31"
    response_due "2014-05-08 13:45:31"
    question { Faker::Lorem.sentence(10) }
    answer nil

    factory :checked_by_finance_pq do
      progress { Progress.find_by(name: Progress.UNASSIGNED) }
      seen_by_finance true
      finance_interest false


      factory :not_responded_pq do
        progress { Progress.find_by(name: Progress.NO_RESPONSE) }

        minister
        after(:create) do |pq, _|
          pq.action_officers << create(:action_officer)
        end
      end
    end


    factory :answered_pq do
      progress { Progress.find_by(name: Progress.ANSWERED) }
    end
  end
end
