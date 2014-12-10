class IWillWriteController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def create
    pq_to_dup = Pq.find_by(uin: params[:id])

    if !pq_to_dup.i_will_write
      return redirect_to action:'pqs', controller: 'show', id: params[:id], notice: 'Error, the PQ is not flag as a \'I will write\''
    end

    uin_iww = "#{pq_to_dup.uin}-IWW"
    exist = Pq.find_by(uin: uin_iww)
    if !exist.nil?
      return redirect_to controller:'pqs', action: 'show', id: uin_iww, notice: "Created PQ 'I will write' #{uin_iww}"
    end

    @pq = pq_to_dup.dup
    @pq.update(
        uin: uin_iww,
        state: :draft_pending
        question_type: "Follow-up IWW",
        draft_answer_received: nil,
        pq_correction_received: nil,
        correction_circulated_to_action_officer: nil,
        pod_clearance: nil,
        sent_to_policy_minister: nil,
        policy_minister_to_action_officer: nil,
        policy_minister_returned_by_action_officer: nil,
        resubmitted_to_policy_minister: nil,
        cleared_by_policy_minister: nil,
        sent_to_answering_minister: nil,
        answering_minister_to_action_officer: nil,
        answering_minister_returned_by_action_officer: nil,
        resubmitted_to_answering_minister: nil,
        cleared_by_answering_minister: nil,
        answer_submitted: nil,
        library_deposit: nil,
        pq_withdrawn: nil,
        holding_reply_flag: nil,
        final_response_info_released: nil,
        round_robin_guidance_received: nil,
        transfer_out_ogd_id: nil,
        transfer_out_date: nil,
        transfer_in_ogd_id: nil,
        transfer_in_date: nil
    )

    if @pq.save
      assignment = pq_to_dup.accepted_assignment
      if !assignment.nil?
        assignment.pq_id = @pq.id
        assignment.save
      end
      return redirect_to controller:'pqs', action: 'show', id: uin_iww, notice: "Created PQ 'I will write' #{uin_iww}"
    end
    return redirect_to controller:'pqs', action: 'show', id: params[:id], notice: 'Error saving the PQ \'I will write\''
  end
end
