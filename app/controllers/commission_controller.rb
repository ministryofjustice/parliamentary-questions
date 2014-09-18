class CommissionController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

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

  def assign
    pq_id = params[:action_officers_pq][:pq_id]
    @pq = Pq.find(pq_id)
    comm = params[:action_officers_pq][:action_officer_id]

    return render text: 'Please select at least the answering minister', status: :bad_request if invalid_ministers

    @pq.minister_id = params[:minister_id]
    @pq.policy_minister_id = params[:policy_minister_id]

    return render text: 'Error saving minister', status: :bad_request if !@pq.save

    return render text: 'Please select at least one Action Officer', status: :bad_request if commission_invalid(comm)

    get_non_empty_commissions(comm).each do |ao_id|
      begin
        if assign_one_action_officer(pq_id, ao_id).nil?
          raise "Error in commissioning to #{assignment.action_officer.name}"
        end
      rescue => e
        flash.now[:error] = "#{e}"
        break
      end
    end
    render :partial => 'shared/question_assigned', :locals => {question: @pq}
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
  
    def assignment_params
      # TODO: Check the permit again
      # params.require(:action_officers_pq).permit(:action_officer_id, :pq_id)
    end

# methods for assign

  def commission_invalid(comm)
    comm.size==1 && comm.first.empty?
  end

  def invalid_ministers
    params[:minister_id].nil? || params[:minister_id].empty?
  end

  def get_non_empty_commissions(comm)
    comm.reject!(&:blank?)
  end
end
