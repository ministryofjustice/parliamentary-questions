FactoryGirl.define do
  factory :question, class: Pq do
    uin { Faker::Lorem.characters(10) }
    house_id 1
    raising_member_id 1
    tabled_date "2014-05-08 13:45:31"
    response_due "2014-05-08 13:45:31"
    text { Faker::Lorem.sentence(10) }
    answer nil
    state { QuestionStateMachine::index_for(:with_finance) }

    factory :question_transferred_in do
      state { QuestionStateMachine::index_for(:transferred_in) }
    end

    factory :question_uncommissioned do
      state { QuestionStateMachine::index_for(:uncommissioned) }

      factory :question_with_officers do
        state { QuestionStateMachine::index_for(:with_officers) }
        internal_deadline { Faker::Date.forward(14) }
        date_for_answer { Faker::Date.between(internal_deadline, internal_deadline + 7.days)}
        minister

        ignore do
          action_officer { create(:action_officer) }
          action_officer_allocated_at { Time.now }
        end

        after(:create) do |pq, evaluator|
          create(:action_officers_pq,
                 pq: pq,
                 action_officer: evaluator.action_officer,
                 created_at: evaluator.action_officer_allocated_at,
                 updated_at: evaluator.action_officer_allocated_at)
        end
      end

      factory :question_rejected do
        state { QuestionStateMachine::index_for(:rejected) }
        after(:create) do |question|
          create(:rejected_action_officers_pq, pq: question)
        end
      end

      factory :question_transferred_out do
        state { QuestionStateMachine::index_for(:transferred_out) }
      end

      factory :question_draft_pending do
        state { QuestionStateMachine::index_for(:draft_pending) }
        internal_deadline { Faker::Date.forward(14) }
        date_for_answer { Faker::Date.between(internal_deadline, internal_deadline + 7.days)}
        minister

        after(:create) do |pq, _|
          pq.action_officers_pqs = [create(:accepted_action_officers_pq, pq: pq)]
        end

        factory :question_with_pod do
          state { QuestionStateMachine::index_for(:with_pod) }
          draft_answer_received { Time.now }

          factory :question_pod_cleared do
            state { QuestionStateMachine::index_for(:pod_cleared) }
            pod_clearance { Time.now }

            factory :question_with_policy_minister do
              state { QuestionStateMachine::index_for(:with_policy_minister) }
              policy_minister

              factory :question_policy_minister_cleared do
                state { QuestionStateMachine::index_for(:policy_minister_cleared) }
                cleared_by_answering_minister { Time.now }
              end

              factory :question_with_answering_minister do
                state { QuestionStateMachine::index_for(:with_answering_minister) }
                sent_to_answering_minister { Time.now }


                factory :question_cleared do
                  state { QuestionStateMachine::index_for(:cleared) }
                  cleared_by_answering_minister { Time.now }
                end
              end
            end
          end
        end
      end
    end


    factory :question_answered do
      state { QuestionStateMachine::index_for(:answered) }
    end
  end
end
