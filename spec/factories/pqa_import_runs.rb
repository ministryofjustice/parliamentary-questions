# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :pqa_import_run, :class => 'Pqa::ImportRun' do
    start_time "2015-05-06 17:12:44"
    end_time "2015-05-06 17:12:44"
    status "MyString"
    num_created 1
    num_updated 1
    errors "MyString"
  end
end
