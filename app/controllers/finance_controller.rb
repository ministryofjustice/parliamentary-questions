class FinanceController < ApplicationController
  before_action :authenticate_user!, FinanceUserFilter

  def questions
    @questions = PQ.not_seen_by_finance.order(:internal_deadline).load
  end

  def confirm
    params[:pq].each do |id, values|
      seen_by_finance = values['seen_by_finance']
      finance_interest = values['finance_interest'] || false
      pq = PQ.find(id)
      pq.update(seen_by_finance: seen_by_finance, finance_interest: finance_interest)
    end

    flash[:notice] = 'Successfully register interest, in the questions'
    redirect_to action: 'questions'
  end

end