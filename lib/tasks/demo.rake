
namespace :demo do

  task :setup => :environment do
    (1..5).each do |i|
      create_question(i)
    end
  end
end



def create_question(i)
  i +=100
  
  question = Pq.create!(
                                         :house_id => nil,
                                :raising_member_id => 2479,
                                      :tabled_date => 1.days.ago,
                                     :response_due => nil,
                                         :question => "Mock question uin-#{i}",
                                           :answer => nil,
                                 :finance_interest => nil,
                                  :seen_by_finance => false,
                                              :uin => "uin-#{i}",
                                      :member_name => "Diana Johnson",
                              :member_constituency => "Kingston upon Hull North",
                                       :house_name => "House of Commons",
                                  :date_for_answer => 2.days.from_now,
                              :registered_interest => false,
                                :internal_deadline => nil,
                                    :question_type => "NamedDay",
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