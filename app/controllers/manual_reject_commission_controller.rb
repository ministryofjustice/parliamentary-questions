class ManualRejectCommissionController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def reject_manual
    ao_pq = ActionOfficersPq.where(id: params[:id]).first

    if ao_pq
      response = AllocationResponse.new(
        reason_option: 'Other Reason',
        reason: t('page.message.pq_allocation_rejected')
      )
      AssignmentService.new.reject(ao_pq, response)

      uin = ao_pq.pq.uin
      flash[:success] = t('page.flash.pq_manually_rejected')
      redirect_to(controller: 'pqs', action: 'show', id: uin)
    else
      flash[:error] = t('page.flash.pq_manual_rejection_error')
      redirect_to(controller: 'dashboard', action: 'index')
    end
  end
end
