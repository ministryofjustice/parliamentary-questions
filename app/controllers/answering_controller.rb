class AnsweringController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :load_service
  before_action :set_pq

  def index
    @pq_answer = PQAnswer.new
    render partial: 'form'
  end

  def answer

    @pq_answer = PQAnswer.new(answer_params)

    if !@pq_answer.valid?
      return render :partial => 'form'
    end

    begin
      @answering_service.answer(@pq, {text: @pq_answer.text, is_holding_answer: @pq_answer.is_holding_answer })
    rescue => err
      flash[:error] = err.to_s
      return render :partial => 'form'
    end

    render :partial => 'answer', :locals => {pq: @pq}
  end

  protected

  def load_service(answering_service = AnsweringService.new)
    @answering_service ||= answering_service
  end

  def set_pq
    @pq = PQ.find(params[:id])
  end

  def answer_params
    params.require(:pq_answer).permit(:text, :is_holding_answer, :id)
  end


end