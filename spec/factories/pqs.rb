# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :Pq do
    uin 'hl1234'
    house_id 1
    raising_member_id 1
    tabled_date "2014-05-08 13:45:31"
    response_due "2014-05-08 13:45:31"
    question "MyString"
    answer nil

    factory :checked_by_finance_pq do
      progress { Progress.find_by(name: Progress.UNASSIGNED) }
      seen_by_finance true
      finance_interest false
    end

    factory :answered_pq do
      progress { Progress.find_by(name: Progress.ANSWERED) }
    end
  end
end
