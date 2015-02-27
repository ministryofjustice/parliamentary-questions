class PqsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def index
    redirect_to controller: 'dashboard'
  end

  def show
    loading_relations
  end

  def update
    loading_relations do
      archive_trim_link!(params[:commit])

      if @pq.update(pq_params)
        PQProgressChangerService.new.update_progress(@pq)

        action_officer_id = params.fetch(:commission_form, {})[:action_officer_id]

        if action_officer_id.present?
          @pq.reassign(ActionOfficer.find(action_officer_id))
        end

        flash[:success] = 'Successfully updated'
        redirect_to action: 'show', id: @pq.uin
      else
        @pq.trim_link(true)
        render action: 'show'
      end
    end
  end

  private

  def loading_relations
    @progress_list = Progress.all
    @ogd_list      = Ogd.all
    @pq            = Pq.find_by(uin: params[:id])

    unless @pq
      flash[:error] = 'Question not found'
      redirect_to action: 'index'
    else
      yield if block_given?
    end
  end

  def archive_trim_link!(action)
    case action
    when 'Delete'
      @pq.trim_link.deactivate!
    when 'Undo'
      @pq.trim_link.activate!
    end
  end

  def pq_params
    params.require(:pq).permit(
      :answer_submitted,
      :answering_minister_query,
      :answering_minister_returned_by_action_officer,
      :answering_minister_to_action_officer,
      :cleared_by_answering_minister,
      :cleared_by_policy_minister,
      :correction_circulated_to_action_officer,
      :date_for_answer,
      :draft_answer_received,
      :final_response_info_released,
      :finance_interest,
      :holding_reply_flag,
      :holding_reply,
      :i_will_write_estimate,
      :i_will_write,
      :internal_deadline,
      :library_deposit,
      :minister_id,
      :pod_clearance,
      :pod_query_flag,
      :pod_query,
      :policy_minister_id,
      :policy_minister_query,
      :policy_minister_returned_by_action_officer,
      :policy_minister_to_action_officer,
      :pq_correction_received,
      :pq_withdrawn,
      :press_interest,
      :progress_id,
      :resubmitted_to_answering_minister,
      :resubmitted_to_policy_minister,
      :round_robin_date,
      :round_robin_guidance_received,
      :round_robin,
      :seen_by_finance,
      :sent_to_answering_minister,
      :sent_to_policy_minister,
      :transfer_in_date,
      :transfer_in_ogd_id,
      :transfer_out_date,
      :transfer_out_ogd_id,
      :with_pod,
      trim_link_attributes: [:file]
    )
  end

  def uppm_params
    params.require(:pq).permit(:policy_minister_id)
  end

  def answering_minister_params
    params.require(:pq).permit(:minister_id)
  end

  def update_deadline_params
    params.require(:pq).permit(:internal_deadline)
  end

  def update_date_for_answer_params
    params.require(:pq).permit(:date_for_answer)
  end
end
