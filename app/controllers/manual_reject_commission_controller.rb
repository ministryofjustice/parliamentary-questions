class ManualRejectCommissionController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :load_service

  def reject_manual
    ao_pq = ActionOfficersPq.find(params[:id])
    if ao_pq.nil?
      return redirect_to({controller: 'dashboard', action: 'index'}, {notice: 'Commission data not found'})
    end

    response = AllocationResponse.new(reason_option: 'Other Reason', reason: "This question is rejected manually by #{current_user.email}")
    @assignment_service.reject(ao_pq, response)

    pq = PQ.find(ao_pq.pq_id)
    redirect_to({controller: 'pqs', action: 'show', id: pq.uin }, {notice: 'Manually rejected, you have to do the commissioning again'})
  end

  private

  def load_service(service = AssignmentService.new)
    @assignment_service ||= service
  end

end