class CommissionController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  # Fixme where is this being used and how (as a GET)?
  def commission
    @pq = Pq.find_by(uin: params[:id])
    if @pq.nil?
      flash[:notice] = 'Question not found'
      redirect_to action: 'index'
    else
      @aap = ActionOfficersPq.new
      @aap.pq_id = @pq.id
      @aap
    end
  end

  # Fixme this should be just 'commision', but same action already exists
  def dashboard_commission
    form = CommissionForm.new(commission_form_params)
    if form.valid?
      # Fixme this all should be 1 transaction (or something like that)

      pq = Pq.find(form.pq_id)
      pq.minister_id = form.minister_id
      pq.policy_minister_id = form.policy_minister_id
      pq.save

      begin
        form.action_officer_id.each do |action_officer_id|
          assign_one_action_officer(pq.id, action_officer_id)
        end

        render :partial => 'shared/question_assigned', :locals => {question: pq}
      rescue Exception => e
        # ToDo there's a follow up story to display error messages
        render text: "Error when commissioning: #{e}", status: 400
      end
    else
      # ToDo there's a follow up story to display error messages
      render text: form.errors.values.flatten.join('\n'), status: 422
    end
  end

  def complete
    @pq = Pq.find_by(uin: params[:id])
    render :partial => 'shared/commissioned', :locals => {uin: @pq}
  end

  private

  def assign_one_action_officer(pq_id, ao_id)
    assignment = ActionOfficersPq.new(pq_id: pq_id, action_officer_id: ao_id)
    comm_service = CommissioningService.new
    result = comm_service.send(assignment)
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
