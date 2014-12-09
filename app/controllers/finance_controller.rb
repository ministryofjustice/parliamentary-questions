class FinanceController < ApplicationController
  before_action :authenticate_user!, FinanceUserFilter

  def questions
    @questions = Pq.in_state(:with_finance).order(:internal_deadline).load
  end

  def confirm
    params[:pq].each do |id, values|
      Pq.find(id).update(
        seen_by_finance: values['seen_by_finance'],
        finance_interest: values['finance_interest']
      )
    end

    flash[:notice] = 'Finance check complete'
    redirect_to action: 'questions'
  end
end
