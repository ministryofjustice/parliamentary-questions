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
    @pq.uin = uin_iww
    @pq.progress_id = Progress.draft_pending.id
    @pq.question_type = "Follow-up IWW"
    @pq.draft_answer_received = nil
    @pq.pq_correction_received = nil
    @pq.correction_circulated_to_action_officer = nil
    @pq.pod_query = nil
    @pq.pod_query_flag = FALSE
    @pq.pod_clearance = nil
    @pq.sent_to_policy_minister                              = nil
    @pq.policy_minister_query                                = nil
    @pq.policy_minister_to_action_officer                    = nil
    @pq.policy_minister_returned_by_action_officer           = nil
    @pq.resubmitted_to_policy_minister                       = nil
    @pq.cleared_by_policy_minister                           = nil
    @pq.sent_to_answering_minister                           = nil
    @pq.answering_minister_query                             = nil
    @pq.answering_minister_to_action_officer                 = nil
    @pq.answering_minister_returned_by_action_officer        = nil
    @pq.resubmitted_to_answering_minister                    = nil
    @pq.cleared_by_answering_minister                        = nil
    @pq.answer_submitted                                     = nil
    @pq.library_deposit                                      = nil
    @pq.pq_withdrawn                                         = nil
    @pq.holding_reply_flag                                   = nil
    @pq.final_response_info_released                         = nil
    @pq.round_robin_guidance_received                        = nil
    @pq.transfer_out_ogd_id                                  = nil
    @pq.transfer_out_date                                    = nil
    @pq.transfer_in_ogd_id                                   = nil
    @pq.transfer_in_date                                     = nil

    if @pq.save
      # duplicate commissioning data
      ao_pq = action_officer_pq_accepted(pq_to_dup)
      if !ao_pq.nil?
        ao_pq.pq_id = @pq.id
        ao_pq.save()
      end
      return redirect_to controller:'pqs', action: 'show', id: uin_iww, notice: "Created PQ 'I will write' #{uin_iww}"
    end
    return redirect_to controller:'pqs', action: 'show', id: params[:id], notice: 'Error saving the PQ \'I will write\''
  end


  private
  def action_officer_pq_accepted(pq)
    pq.action_officers_pq.each do |ao_pq|
      if ao_pq.accept
        return ao_pq
      end
    end
    return nil
  end

end