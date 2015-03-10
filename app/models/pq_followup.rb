module PqFollowup
  def find_or_create_follow_up
    unless i_will_write && follow_up_to.blank? && valid?
      raise "A PQ follow-up must be valid, have 'i_will_write' set to true, and 'follow_up_to' blank!"
    end

    ActiveRecord::Base.transaction do
      follow_up = self.class.find_or_initialize_by(uin: iww_uin)

      if follow_up.new_record?
        attrs = attributes
                  .reject { |k,_| FOLLOW_UP_ATTR_RESET.include?(k) }
                  .merge('question_type' => 'Follow-up IWW',
                         'i_will_write'  => true,
                         'follow_up_to'  => uin,
                         'progress'      => Progress.draft_pending)

        follow_up.update!(attrs)

        ao_pq = action_officers_pqs.find(&:accepted?)
        ao_pq.update(pq_id: follow_up.id) if ao_pq
      end

      follow_up
    end
  end


  def has_follow_up?
    self.class.exists?(follow_up_to: uin)
  end

  def is_follow_up?
    i_will_write && follow_up_to.present?
  end

  FOLLOW_UP_ATTR_RESET = [
    'id',
    'uin',
    'draft_answer_received',
    'pq_correction_received',
    'correction_circulated_to_action_officer',
    'pod_query',
    'pod_query_flag',
    'pod_clearance',
    'sent_to_policy_minister',
    'policy_minister_query',
    'policy_minister_to_action_officer',
    'policy_minister_returned_by_action_officer',
    'resubmitted_to_policy_minister',
    'cleared_by_policy_minister',
    'sent_to_answering_minister',
    'answering_minister_query',
    'answering_minister_to_action_officer',
    'answering_minister_returned_by_action_officer',
    'resubmitted_to_answering_minister',
    'cleared_by_answering_minister',
    'answer_submitted',
    'library_deposit',
    'pq_withdrawn',
    'holding_reply_flag',
    'final_response_info_released',
    'round_robin_guidance_received',
    'transfer_out_ogd_id',
    'transfer_out_date',
    'transfer_in_ogd_id',
    'transfer_in_date',
  ]
end
