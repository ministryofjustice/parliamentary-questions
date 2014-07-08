
class ManualRejectCommissionController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :load_service

  def reject_manual
    ao_pq = ActionOfficersPq.find(params[:id])
    if ao_pq.nil?
      flash[:warning] = 'Commission data not found'
      return render partial: 'shared/flash_messages'
    end

    response = AllocationResponse.new(reason_option: 'Other Reason', reason: "This question is rejected manually by #{current_user.email}")
    @assignment_service.reject(ao_pq, response)

    flash[:warning] = 'Manually rejected, you have to do the commissioning again'
    render partial: 'shared/flash_messages'
  end

  private

  def load_service(service = AssignmentService.new)
    @assignment_service ||= service
  end

end