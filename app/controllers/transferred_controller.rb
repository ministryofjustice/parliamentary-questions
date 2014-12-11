class TransferredController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :prepare_ogds

  def new
    @pq = Pq.new
  end

  def create
    @pq = Pq.new(pq_params)
    @pq.transferred = true
    @pq.raising_member_id = '0'
    @pq.progress_id = Progress.unassigned.id


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
    params.require(:pq).permit(:uin,
                               :question,
                               :house_name,
                               :member_name,
                               :member_constituency,
                               :date_for_answer,
                               :registered_interest,
                               :question_type,
                               :transfer_in_ogd_id,
                               :transfer_in_date)
  end

  def prepare_ogds
    @ogd_list = Ogd.all
  end
end
