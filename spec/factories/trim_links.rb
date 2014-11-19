# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trim_link do
    filename "trim_link.tr5"
    size 1
    data "binarydata?"
    pq_id 1
  end
end
