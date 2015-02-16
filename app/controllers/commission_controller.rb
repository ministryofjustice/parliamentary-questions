class CommissionController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def commission
    form       = CommissionForm.new(commission_form_params)
    pq, status =
      if form.valid?
        [CommissioningService.new.commission(form), 200]
      else
        flash.now[:error] = "Error in commissioning question"
        [Pq.find_by(uin: params[:id]), 422]
      end

    render(partial: 'shared/question_assigned',
           locals: { question: pq },
           status: status)
  end

  def complete
    @pq = Pq.find_by(uin: params[:id])
    render :partial => 'shared/commissioned', :locals => {uin: @pq}
  end

  private

  def commission_form_params
    params.require(:commission_form)
      .permit(:pq_id, :minister_id, :policy_minister_id,
             { action_officer_id: [] },
             :date_for_answer, :internal_deadline)
  end
end
