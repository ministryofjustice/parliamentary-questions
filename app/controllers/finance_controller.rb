class FinanceController < ApplicationController
  before_action :authenticate_user!, FinanceUserFilter

  def questions
    @page_title = t('page.title.finance')
    @questions  = Pq.new_questions.sorted_for_dashboard
  end

  def confirm
    params[:pq].each do |id, values|
      finance_interest = values['finance_interest'] || false
      pq = Pq.find(id)
      pq.update(finance_interest:)
    end

    flash[:success] = t('page.flash.finance_interest.success')
    redirect_to action: 'questions'
  end
end
