class TransferredController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  before_action :set_minister, only: [:show, :edit, :update, :destroy]


  def new
    @pq = PQ.new
  end

  def create
    @pq = PQ.new(pq_params)
    @pq.transferred = true
    @pq.raising_member_id = '0'
    @pq.question = 'This question is mark as a transferred, the text of the question it should appear once the transfer is received'
    @pq.save

    flash[notice] = 'Transferred PQ was successfully created.'
    redirect_to controller: 'dashboard', action: 'index'
  end

  private

  def pq_params
    params.require(:pq).permit(:uin)
  end


end