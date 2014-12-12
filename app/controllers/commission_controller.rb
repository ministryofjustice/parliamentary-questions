class CommissionController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def commission
    form = CommissionForm.new(commission_form_params)
    if form.valid?
      pq = Pq.find(form.pq_id)
      pq.minister_id = form.minister_id
      pq.policy_minister_id = form.policy_minister_id
      pq.date_for_answer = form.date_for_answer
      pq.internal_deadline = form.internal_deadline
      pq.save

      begin
        form.action_officer_id.each do |action_officer_id|
          assign_one_action_officer(pq.id, action_officer_id)
        end

        render :partial => 'shared/question_assigned', :locals => {question: pq}
      rescue Exception => e
        render text: "Error when commissioning: #{e}", status: 400
      end
      pq.reload.transition
    else
      render text: form.errors.values.flatten.join('\n'), status: 422
    end
  end

private

  def assign_one_action_officer(pq_id, ao_id)
    assignment = ActionOfficersPq.new(pq_id: pq_id, action_officer_id: ao_id)
    comm_service = CommissioningService.new
    result = comm_service.commission(assignment)
    if result.nil?
      flash.now[:error] = "Error in commissioning to #{assignment.action_officer.name}"
      return render :partial => 'shared/question_assigned', :locals => {question: @pq}
    else
      comm_service.notify_dd(assignment)
    end
  end

  def commission_form_params
    params.require(:commission_form).permit(
      :pq_id, :minister_id, :policy_minister_id, {action_officer_id: []}, :date_for_answer, :internal_deadline)
  end
end
