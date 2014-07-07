class TransferredController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def new
    @pq = PQ.new
  end

  def create
    @pq = PQ.new(pq_params)
    @pq.transferred = true
    @pq.raising_member_id = '0'
    @pq.progress_id = Progress.UNALLOCATED


    if @pq.save
      flash[notice] = 'Transferred PQ was successfully created.'
      redirect_to controller: 'dashboard', action: 'index'
    else
      flash[notice] = 'There was an error creating the transfer PQ.'
      render :new


    end
  end

  private

  def pq_params
    params.require(:pq).permit(:uin, :question, :house_name, :member_name, :member_constituency, :date_for_answer, :registered_interest, :type_of_question )
  end


end