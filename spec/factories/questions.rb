FactoryGirl.define do
  factory :question, class: Pq, aliases: [:question_with_finance] do
    uin { Faker::Lorem.characters(10) }
    house_id 1
    raising_member_id 1
    tabled_date { Date.yesterday }
    text { Faker::Lorem.sentence(10) }
    state { QuestionStateMachine::index_for(:with_finance) }

    ignore do
      age Time.now
    end
  end

  factory :question_uncommissioned, parent: :question do
    state { QuestionStateMachine::index_for(:uncommissioned) }
  end

  factory :question_with_officers, parent: :question_uncommissioned do
    internal_deadline { Faker::Date.forward(5) }
    date_for_answer { Faker::Date.between(internal_deadline, internal_deadline + 3.days) }
    minister
    after(:create) do |question, evaluator|
      create(:action_officers_pq, pq: question, created_at: evaluator.age, updated_at: evaluator.age)
      question.transition
    end
  end

  factory :question_rejected, parent: :question_with_officers do
    after(:create) do |question|
      question.action_officers_pqs.first.reject('option', 'reason')
      question.transition
    end
  end

  factory :question_draft_pending, parent: :question_with_officers do
    after(:create) do |question|
      question.action_officers_pqs.first.accept
      question.transition
    end
  end

  factory :question_with_pod, parent: :question_draft_pending do
    draft_answer_received { Faker::Date.between(3.days.ago, 2.days.ago) }
    after(:create) { |question| question.transition }
  end

  factory :question_pod_cleared, parent: :question_with_pod do
    pod_clearance { Faker::Date.between(draft_answer_received, draft_answer_received + 1.day) }
    after(:create) { |question| question.transition }
  end

  factory :question_with_policy_minister, parent: :question_pod_cleared do
    policy_minister
    sent_to_policy_minister { Faker::Date.between(pod_clearance, pod_clearance + 1.day) }
    after(:create) { |question| question.transition }
  end

  factory :question_policy_minister_cleared, parent: :question_with_policy_minister do
    cleared_by_policy_minister { Faker::Date.between(sent_to_policy_minister, sent_to_policy_minister + 1.day) }
    after(:create) { |question| question.transition }
  end

  factory :question_with_answering_minister, parent: :question_policy_minister_cleared do
    sent_to_answering_minister { 2.hours.ago }
    after(:create) { |question| question.transition }
  end

  factory :question_answering_minister_cleared, parent: :question_with_answering_minister do
    cleared_by_answering_minister { 1.hour.ago }
    after(:create) { |question| question.transition }
  end

  factory :question_answered, parent: :question_answering_minister_cleared do
    answer_submitted { 10.minutes.ago }
    after(:create) { |question| question.transition }
  end

  factory :question_withdrawn, parent: :question_answering_minister_cleared do
    pq_withdrawn { 5.minutes.ago }
    after(:create) { |question| question.transition }
  end

  factory :question_transferred_out, parent: :question_with_officers do
    sequence(:transfer_out_ogd_id)
    transfer_out_date { 3.minutes.ago }
    after(:create) { |question| question.transition }
  end
end
