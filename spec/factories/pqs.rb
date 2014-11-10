FactoryGirl.define do
  factory :pq do
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

      factory :accepted_pq do
        progress { Progress.find_by(name: Progress.ACCEPTED) }
        internal_deadline { Faker::Date.forward(14) }
        date_for_answer { Faker::Date.between(internal_deadline, internal_deadline + 7.days)}
        minister

        after(:create) do |pq, _|
          pq.action_officers_pq = [create(:accepted_action_officers_pq, pq: pq)]
        end

        factory :draft_pending_pq do
          progress { Progress.find_by(name: Progress.DRAFT_PENDING) }
        end

        factory :with_pod_pq do
          progress { Progress.find_by(name: Progress.WITH_POD) }
          draft_answer_received { Time.now }

          factory :pod_query_pq do
            progress { Progress.find_by(name: Progress.POD_QUERY) }
            pod_query_flag true

            factory :pod_cleared_pq do
              progress { Progress.find_by(name: Progress.POD_CLEARED) }
              pod_clearance { Time.now }

              factory :with_minister_pq do
                progress { Progress.find_by(name: Progress.WITH_MINISTER) }
                sent_to_answering_minister { Time.now }

                factory :ministerial_query_pq do
                  progress { Progress.find_by(name: Progress.MINISTERIAL_QUERY) }
                  answering_minister_query true
                end

                factory :minister_cleared_pq do
                  progress { Progress.find_by(name: Progress.MINISTER_CLEARED) }
                  cleared_by_answering_minister { Time.now }
                end
              end
            end
          end
        end
      end
    end


    factory :answered_pq do
      progress { Progress.find_by(name: Progress.ANSWERED) }
    end
  end
end
