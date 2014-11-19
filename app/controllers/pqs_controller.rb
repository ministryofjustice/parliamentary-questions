class PqsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_pq, only: [:show, :update, :assign_minister, :assign_answering_minister]
  before_action :archive_trim_link, only: :update
  before_action :prepare_progresses
  before_action :prepare_ogds
  before_action :load_service

  def index
    redirect_to controller: 'dashboard'
  end

  def show
    @pq = Pq.find_by(uin: params[:id])
    if !@pq.present?
      flash[:notice] = 'Question not found'
      redirect_to action: 'index'
    end
  end

  def update
    if @pq.update(pq_params)
      flash[:success] = 'Successfully updated'
      @pq_progress_changer_service.update_progress(@pq)
      redirect_to action: 'show', id: @pq.uin
    else
      @pq.trim_link(true)
      render action: 'show'
    end
  end

private

  def archive_trim_link
    if params[:commit] == 'Delete'
      @pq.trim_link.archive
    elsif params[:commit] == 'Undo'
      @pq.trim_link.unarchive
    end
  end

  def set_pq
    @pq = Pq.find_by(uin: params[:id])
  end

  def load_service(pq_progress_changer_service = PQProgressChangerService.new)
    @pq_progress_changer_service ||= pq_progress_changer_service
  end

  def pq_params
    @pq_params ||= params.require(:pq).permit(
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

  def prepare_progresses
    @progress_list = Progress.all
  end

  def prepare_ogds
    @ogd_list = Ogd.all
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
