# == Schema Information
#
# Table name: pqs
#
#  id                                            :integer          not null, primary key
#  house_id                                      :integer
#  raising_member_id                             :integer
#  tabled_date                                   :datetime
#  response_due                                  :datetime
#  question                                      :text
#  answer                                        :string(255)
#  created_at                                    :datetime
#  updated_at                                    :datetime
#  finance_interest                              :boolean
#  seen_by_finance                               :boolean          default(FALSE)
#  uin                                           :string(255)
#  member_name                                   :string(255)
#  member_constituency                           :string(255)
#  house_name                                    :string(255)
#  date_for_answer                               :date
#  registered_interest                           :boolean
#  internal_deadline                             :datetime
#  question_type                                 :string(255)
#  minister_id                                   :integer
#  policy_minister_id                            :integer
#  progress_id                                   :integer
#  draft_answer_received                         :datetime
#  i_will_write_estimate                         :datetime
#  holding_reply                                 :datetime
#  preview_url                                   :string(255)
#  pod_waiting                                   :datetime
#  pod_query                                     :datetime
#  pod_clearance                                 :datetime
#  transferred                                   :boolean
#  question_status                               :string(255)
#  round_robin                                   :boolean
#  round_robin_date                              :datetime
#  i_will_write                                  :boolean
#  pq_correction_received                        :boolean
#  correction_circulated_to_action_officer       :datetime
#  pod_query_flag                                :boolean
#  sent_to_policy_minister                       :datetime
#  policy_minister_query                         :boolean
#  policy_minister_to_action_officer             :datetime
#  policy_minister_returned_by_action_officer    :datetime
#  resubmitted_to_policy_minister                :datetime
#  cleared_by_policy_minister                    :datetime
#  sent_to_answering_minister                    :datetime
#  answering_minister_query                      :boolean
#  answering_minister_to_action_officer          :datetime
#  answering_minister_returned_by_action_officer :datetime
#  resubmitted_to_answering_minister             :datetime
#  cleared_by_answering_minister                 :datetime
#  answer_submitted                              :datetime
#  library_deposit                               :boolean
#  pq_withdrawn                                  :datetime
#  holding_reply_flag                            :boolean
#  final_response_info_released                  :string(255)
#  round_robin_guidance_received                 :datetime
#  transfer_out_ogd_id                           :integer
#  transfer_out_date                             :datetime
#  directorate_id                                :integer
#  division_id                                   :integer
#  transfer_in_ogd_id                            :integer
#  transfer_in_date                              :datetime
#  follow_up_to                                  :string(255)
#  state                                         :string(255)      default("unassigned")
#  state_weight                                  :integer          default(0)
#

FactoryGirl.define do
  factory :pq do
    uin { Faker::Lorem.characters(10) }
    house_id 1
    raising_member_id 1
    tabled_date "2014-05-08 13:45:31"
    response_due "2014-05-08 13:45:31"
    question { Faker::Lorem.sentence(10) }
    answer nil
    state PQState::UNASSIGNED

    factory :checked_by_finance_pq do
      seen_by_finance true
      finance_interest false

      factory :not_responded_pq do
        state PQState::NO_RESPONSE
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

      factory :draft_pending_pq do
        state PQState::DRAFT_PENDING
        internal_deadline { Faker::Date.forward(14) }
        date_for_answer { Faker::Date.between(internal_deadline, internal_deadline + 7.days)}
        minister

        after(:create) do |pq, _|
          pq.action_officers_pqs = [create(:accepted_action_officers_pq, pq: pq)]
        end

        factory :with_pod_pq do
          state PQState::WITH_POD
          draft_answer_received { Time.now }

          factory :pod_query_pq do
            state PQState::POD_QUERY
            pod_query_flag true

            factory :pod_cleared_pq do
              state PQState::POD_CLEARED
              pod_clearance { Time.now }

              factory :with_minister_pq do
                state PQState::WITH_MINISTER
                sent_to_answering_minister { Time.now }

                factory :ministerial_query_pq do
                  state PQState::MINISTERIAL_QUERY
                  answering_minister_query true
                end

                factory :minister_cleared_pq do
                  state PQState::MINISTER_CLEARED
                  cleared_by_answering_minister { Time.now }
                end
              end
            end
          end
        end
      end
    end

    factory :answered_pq do
      state PQState::ANSWERED
    end
  end
end
