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
        archive_trim_link!(params[:commit])

        if @pq.update(pq_params)
          PQProgressChangerService.new.update_progress(@pq)
          reassign_ao_if_present(@pq)
          flash[:success] = 'Successfully updated'
        else
          @pq.trim_link(true)
          flash[:error] = 'Update failed'
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
    flash[:error] = 'Invalid date input!'
    set_dashboard_title
    render :show
  end

  def loading_relations
    @progress_list = Progress.all
    @ogd_list      = Ogd.all
    @pq            = Pq.find_by!(uin: params[:id])
    yield if block_given?
  end

  def archive_trim_link!(action)
    case action
    when 'Delete'
      @pq.trim_link.deactivate!
    when 'Undo'
      @pq.trim_link.activate!
    end
  end

  def reassign_ao_if_present(pq)
    action_officer_id = params.fetch(:commission_form, {})[:action_officer_id]
    pq.reassign(ActionOfficer.find(action_officer_id)) if action_officer_id.present?
  end

  def pq_params
    whitelist = PARAMS + DATE_PARAMS
    params.require(:pq).permit(*whitelist)
  end

  PARAMS = [
    :answering_minister_query,
    :final_response_info_released,
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
    :seen_by_finance,
    :transfer_in_ogd_id,
    :transfer_out_ogd_id,
    :with_pod,
    trim_link_attributes: [:file]
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
