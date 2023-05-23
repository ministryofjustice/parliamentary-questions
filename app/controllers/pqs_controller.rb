class PqsController < ApplicationController
  include Validators::DateInput

  before_action :authenticate_user!, PQUserFilter

  def index
    redirect_to controller: 'dashboard'
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
          flash.now[:success] = t('page.flash.pq_updated')
        else
          flash.now[:error] = t('page.flash.pq_update_failed')
        end
        set_dashboard_title
        render :show
      end
    end
  end

  private

  def set_dashboard_title
    update_page_title(t('page.title.pq_dashboard_title'))
  end

  def with_valid_dates
    DATE_PARAMS.each { |key| pq_params[key].present? && parse_datetime(pq_params[key]) }
    yield
  rescue DateTimeInputError
    flash[:error] = t('page.flash.pq_invalid_date')
    set_dashboard_title
    render :show
  end

  def loading_relations
    @ogd_list        = Ogd.all
    @pq              = Pq.find_by!(uin: params[:id])
    @action_officers = ActionOfficer.active
    yield if block_given?
  end

  def reassign_ao_if_present(pq)
    action_officer_id = params.fetch(:commission_form, {})[:action_officer_id]
    pq.reassign(ActionOfficer.find(action_officer_id)) if action_officer_id.present?
  end

  def pq_params
    allowlist = PARAMS + DATE_PARAMS
    params.require(:pq).permit(*allowlist)
  end

  PARAMS = [
    :answering_minister_query,
    :finance_interest,
    :holding_reply_flag,
    :i_will_write,
    :library_deposit,
    :minister_id,
    :pod_query_flag,
    :policy_minister_id,
    :policy_minister_query,
    :pq_correction_received,
    :press_interest,
    :progress_id,
    :round_robin,
    :transfer_in_ogd_id,
    :transfer_out_ogd_id,
    :with_pod
  ]

  DATE_PARAMS = [
    :date_for_answer,
    :internal_deadline,
    :draft_answer_received,
    :i_will_write_estimate,
    :holding_reply,
    :pod_query,
    :pod_clearance,
    :round_robin_date,
    :correction_circulated_to_action_officer,
    :sent_to_policy_minister,
    :policy_minister_to_action_officer,
    :policy_minister_returned_by_action_officer,
    :resubmitted_to_policy_minister,
    :cleared_by_policy_minister,
    :sent_to_answering_minister,
    :answering_minister_to_action_officer,
    :answering_minister_returned_by_action_officer,
    :resubmitted_to_answering_minister,
    :cleared_by_answering_minister,
    :answer_submitted,
    :pq_withdrawn,
    :round_robin_guidance_received,
    :transfer_out_date,
    :transfer_in_date
  ]
end
