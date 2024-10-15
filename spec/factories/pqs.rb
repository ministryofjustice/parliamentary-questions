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
#  answer                                        :string
#  created_at                                    :datetime         not null
#  updated_at                                    :datetime         not null
#  uin                                           :string
#  member_name                                   :string
#  member_constituency                           :string
#  house_name                                    :string
#  date_for_answer                               :date
#  registered_interest                           :boolean
#  internal_deadline                             :datetime
#  question_type                                 :string
#  minister_id                                   :integer
#  policy_minister_id                            :integer
#  progress_id                                   :integer
#  draft_answer_received                         :datetime
#  holding_reply                                 :datetime
#  preview_url                                   :string
#  pod_waiting                                   :datetime
#  pod_clearance                                 :datetime
#  transferred                                   :boolean
#  question_status                               :string
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
#  final_response_info_released                  :string
#  transfer_out_ogd_id                           :integer
#  transfer_out_date                             :datetime
#  directorate_id                                :integer
#  original_division_id                          :integer
#  transfer_in_ogd_id                            :integer
#  transfer_in_date                              :datetime
#  state                                         :string           default("unassigned")
#  state_weight                                  :integer          default(0)
#  archived                                      :boolean          default(FALSE)
#

FactoryBot.define do
  factory :pq do
    uin { "1#{Faker::Lorem.characters(number: 10)}" }
    house_id { 1 }
    raising_member_id { 1 }
    tabled_date { "2014-05-08 13:45:31" }
    response_due { "2014-05-08 13:45:31" }
    question { Faker::Lorem.sentence(word_count: 10) }
    answer { nil }
    state { PqState::UNASSIGNED }
    member_name { "Diana Johnson" }

    factory :not_responded_pq do
      state { PqState::NO_RESPONSE }
      internal_deadline { Faker::Date.forward(days: 14) }
      date_for_answer { Faker::Date.between(from: internal_deadline, to: internal_deadline + 7.days) }
      minister

      transient do
        action_officer { create(:action_officer) }
        action_officer_allocated_at { Time.zone.now }
      end

      after(:create) do |pq, evaluator|
        create(:action_officers_pq,
               pq:,
               action_officer: evaluator.action_officer,
               created_at: evaluator.action_officer_allocated_at,
               updated_at: evaluator.action_officer_allocated_at)
      end
    end

    factory :draft_pending_pq do
      state { PqState::DRAFT_PENDING }
      internal_deadline { Faker::Date.forward(days: 14) }
      date_for_answer { Faker::Date.between(from: internal_deadline, to: internal_deadline + 7.days) }
      minister

      after(:create) do |pq, _|
        pq.action_officers_pqs = create_list(:accepted_action_officers_pq, 1, pq:)
      end

      factory :with_pod_pq do
        state { PqState::WITH_POD }
        draft_answer_received { Time.zone.now }

        factory :pod_cleared_pq do
          state { PqState::POD_CLEARED }
          pod_clearance { Time.zone.now }

          factory :with_minister_pq do
            state { PqState::WITH_MINISTER }
            sent_to_answering_minister { Time.zone.now }

            factory :ministerial_query_pq do
              state { PqState::MINISTERIAL_QUERY }
              answering_minister_query { true }
            end

            factory :minister_cleared_pq do
              state { PqState::MINISTER_CLEARED }
              cleared_by_answering_minister { Time.zone.now }
            end
          end
        end
      end
    end

    factory :answered_pq do
      state { PqState::ANSWERED }
    end
  end
end
