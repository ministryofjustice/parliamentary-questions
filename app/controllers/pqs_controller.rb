class PqsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_pq, only: [:show, :update, :assign_minister, :assign_answering_minister, :set_internal_deadline]
  before_action :prepare_ministers 
  before_action :prepare_progresses 
  

  def index
    redirect_to controller: 'dashboard'
  end

  # GET /pqs/1
  # GET /pqs/1.json
  def show
    @pq = PQ.find_by(uin: params[:id])
    if !@pq.present?
      flash[:notice] = 'Question not found'
      redirect_to action: 'index'
    end
    @pq
  end


  # PATCH/PUT /pqs/1
  # PATCH/PUT /pqs/1.json
  def update
    respond_to do |format|
      if @pq.update(pq_params)
        flash[:success] = 'Successfully updated'
        format.html { redirect_to action: 'show', id: @pq.uin }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @pq.errors, status: :unprocessable_entity }
      end
    end
  end

  def assign_minister
    @pq.policy_minister_id = uppm_params[:policy_minister_id]

    if @pq.save
      return render :nothing =>  true
    end

    raise 'Error saving minister'
end



  def assign_answering_minister
    @pq.minister_id = answering_minister_params[:minister_id]

    if @pq.save
      return render :nothing =>  true
    end

    raise 'Error saving minister'
  end

  def set_internal_deadline
    @pq.internal_deadline = update_deadline_params[:internal_deadline]
    if @pq.save
      return render :nothing=>true
    end

    raise 'Error saving internal deadline'
  end

  # DELETE /pqs/1
  # DELETE /pqs/1.json
  #def destroy
  #  @pq.destroy
  #  respond_to do |format|
  #    format.html { redirect_to pqs_url }
  #    format.json { head :no_content }
  #  end
  #end

private
  def set_pq
    @pq = PQ.find_by(uin: params[:id])
  end

  def pq_params
    params.require(:pq).permit(
        :internal_deadline,
        :seen_by_finance,
        :press_interest,
        :finance_interest,
        :minister_id,
        :policy_minister_id,
        :draft_answer_received,
        :i_will_write_estimate,
        :holding_reply,
        :pod_waiting,
        :pod_query,
        :pod_clearance,
        :round_robin,
        :round_robin_date,
        :progress_id,
        :i_will_write,
        :pq_correction_received,
        :correction_circulated_to_action_officer,
        :pod_query_flag,
        :sent_to_policy_minister,
        :policy_minister_query,
        :policy_minister_to_action_officer,
        :policy_minister_returned_by_action_officer,
        :resubmitted_to_policy_minister,
        :cleared_by_policy_minister,
        :sent_to_answering_minister,
        :answering_minister_query,
        :answering_minister_to_action_officer,
        :answering_minister_returned_by_action_officer,
        :resubmitted_to_answering_minister,
        :cleared_by_answering_minister,
        :answer_submitted,
        :library_deposit,
        :pq_withdrawn,
        :holding_reply_flag,
        :final_response_info_released,
        :round_robin_guidance_received
    )
  end
  def prepare_ministers
    @minister_list = Minister.where(deleted: false).all
  end
  def assignment_params
    # TODO: Check the permit again
    # params.require(:action_officers_pq).permit(:action_officer_id, :pq_id)
  end
  def prepare_progresses
    @progress_list = Progress.all
  end
  def uppm_params
    params.require(:pq).permit(:policy_minister_id)
  end
  def answering_minister_params
    params.require(:pq).permit(:minister_id)
  end
  def update_deadline_params
    params.require(:pq).permit(:internal_deadline)
  end
end
