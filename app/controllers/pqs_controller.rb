class PqsController < ApplicationController
  include Validators::DateInput

  before_action :authenticate_user!, PqUserFilter

  def index
    redirect_to controller: "dashboard"
  end

  def show
    loading_relations
    set_dashboard_title
  end

  def update
    loading_relations do
      with_valid_dates do
        if @pq.update(pq_params)
          @pq.update_state!
          reassign_ao_if_present(@pq)
          flash[:success] = "Successfully updated"
        else
          flash[:error] = "Update failed"
        end
        set_dashboard_title
        render :show
      end
    end
  end

private

  def set_dashboard_title
    update_page_title("PQ #{@pq.uin}")
  end

  def with_valid_dates
    DATE_PARAMS.each { |key| pq_params[key].present? && parse_datetime(pq_params[key]) }
    yield
  rescue DateTimeInputError
    flash[:error] = "Invalid date input!"
    set_dashboard_title
    render :show
  end

  def loading_relations
    @ogd_list        = Ogd.all
    @pq              = Pq.find_by!(uin: params[:id])
    @action_officers = ActionOfficer.active
    yield if block_given?
  end

  def reassign_ao_if_present(parliamentary_question)
    action_officer_id = params.fetch(:commission_form, {})[:action_officer_id]
    parliamentary_question.reassign(ActionOfficer.find(action_officer_id)) if action_officer_id.present?
  end

  def pq_params
    allowlist = PARAMS + DATE_PARAMS
    params.require(:pq).permit(*allowlist)
  end

  PARAMS = %i[
    answering_minister_query
    finance_interest
    holding_reply_flag
    i_will_write
    library_deposit
    minister_id
    pod_query_flag
    policy_minister_id
    policy_minister_query
    pq_correction_received
    press_interest
    progress_id
    round_robin
    transfer_in_ogd_id
    transfer_out_ogd_id
    with_pod
  ].freeze

  DATE_PARAMS = %i[
    date_for_answer
    internal_deadline
    draft_answer_received
    i_will_write_estimate
    holding_reply
    pod_query
    pod_clearance
    round_robin_date
    correction_circulated_to_action_officer
    sent_to_policy_minister
    policy_minister_to_action_officer
    policy_minister_returned_by_action_officer
    resubmitted_to_policy_minister
    cleared_by_policy_minister
    sent_to_answering_minister
    answering_minister_to_action_officer
    answering_minister_returned_by_action_officer
    resubmitted_to_answering_minister
    cleared_by_answering_minister
    answer_submitted
    pq_withdrawn
    round_robin_guidance_received
    transfer_out_date
    transfer_in_date
  ].freeze
end
