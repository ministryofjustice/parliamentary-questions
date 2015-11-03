class FinanceController < ApplicationController
  before_action :authenticate_user!, FinanceUserFilter

  def questions
    @page_title = 'New PQs today'
    @questions = Pq.new_questions.sorted_for_dashboard
  end

  def confirm
    params[:pq].each do |id, values|
      finance_interest = values['finance_interest'] || false
      pq = Pq.find(id)
      pq.update(finance_interest: finance_interest)
    end

    flash[:success] = 'Successfully registered interest in the questions'
    redirect_to action: 'questions'
  end
end
