FactoryBot.define do
  factory :proposal_form do
    pq_id { 1 }
    action_officer_id { [create(:action_officer).id] }
  end
end
