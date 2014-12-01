FactoryGirl.define do
  factory :action_officers_pq do
    action_officer

    factory :accepted_action_officers_pq do
      response 'accepted'
    end

    factory :rejected_action_officers_pq do
      response 'rejected'
    end
  end
end
