
namespace :demo do

  task :setup => :environment do
    delete_existing_demo_questions
    seed_questions = populate_seeds
    (1..5).each do |i|
      create_question(i, seed_questions[i - 1])
    end
  end
end


def delete_existing_demo_questions
  Pq.where("uin like 'uin-%'").map(&:destroy)
end


def populate_seeds
  seed_question_uins = %w{ 201828 208682 209418 209416 210144 }
  seed_questions = []
  seed_question_uins.each { |uin| seed_questions << Pq.find_by(uin: uin) }
  seed_questions
end


def create_question(i, seed_question)
  i +=100
  
  question = Pq.create!(
                                         :house_id => nil,
                                :raising_member_id => 2479,
                                      :tabled_date => 1.days.ago,
                                     :response_due => nil,
                                         :question => seed_question.question,
                                           :answer => nil,
                                 :finance_interest => nil,
                                  :seen_by_finance => false,
                                              :uin => "uin-#{i}",
                                      :member_name => seed_question.member_name,
                              :member_constituency => seed_question.member_constituency,
                                       :house_name => "House of Commons",
                                  :date_for_answer => 2.days.from_now,
                              :registered_interest => false,
                                :internal_deadline => nil,
                                    :question_type => seed_question.question_type,
                                      :minister_id => nil,
                               :policy_minister_id => nil,
                                      :progress_id => nil,
                            :draft_answer_received => nil,
                            :i_will_write_estimate => nil,
                                    :holding_reply => nil,
                                      :preview_url => nil,
                                      :pod_waiting => nil,
                                        :pod_query => nil,
                                    :pod_clearance => nil,
                                      :transferred => false,
                                  :question_status => "Tabled",
                                      :round_robin => nil,
                                 :round_robin_date => nil,
                                     :i_will_write => nil,
                           :pq_correction_received => nil,
          :correction_circulated_to_action_officer => nil,
                                   :pod_query_flag => nil,
                          :sent_to_policy_minister => nil,
                            :policy_minister_query => nil,
                :policy_minister_to_action_officer => nil,
       :policy_minister_returned_by_action_officer => nil,
                   :resubmitted_to_policy_minister => nil,
                       :cleared_by_policy_minister => nil,
                       :sent_to_answering_minister => nil,
                         :answering_minister_query => nil,
             :answering_minister_to_action_officer => nil,
    :answering_minister_returned_by_action_officer => nil,
                :resubmitted_to_answering_minister => nil,
                    :cleared_by_answering_minister => nil,
                                 :answer_submitted => nil,
                                  :library_deposit => nil,
                                     :pq_withdrawn => nil,
                               :holding_reply_flag => nil,
                     :final_response_info_released => nil,
                    :round_robin_guidance_received => nil,
                              :transfer_out_ogd_id => nil,
                                :transfer_out_date => nil,
                                   :directorate_id => nil,
                                      :division_id => nil,
                               :transfer_in_ogd_id => nil,
                                 :transfer_in_date => nil,
                                     :follow_up_to => nil,
                                            :state => "unassigned",
                                     :state_weight => 0
  )
end