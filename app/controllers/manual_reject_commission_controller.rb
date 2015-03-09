class ManualRejectCommissionController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def reject_manual
    ao_pq = ActionOfficersPq.where(id: params[:id]).first

    unless ao_pq
      redirect_to(
        { controller: 'dashboard', action: 'index' }, 
        { notice: 'Commission data not found' }
      )
    else
      response = AllocationResponse.new(
        reason_option: 'Other Reason', 
        reason: "This question was rejected manually by #{current_user.email}"
      )
      AssignmentService.new.reject(ao_pq, response)
      
      uin = ao_pq.pq.uin
      redirect_to(
        { controller: 'pqs', action: 'show', id: uin }, 
        { notice: "#{uin} manually rejected, check if you have to do the commissioning again" }
      )
    end
  end
end
