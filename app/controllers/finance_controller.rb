class FinanceController < ApplicationController
  before_action :authenticate_user!, FinanceUserFilter
  before_action :load_import_service

  def questions
    #TODO refactor to not allways call import in the PQ API
    result_imported = @import_service.questions()
    #@questions = result_imported[:questions]

    @questions = PQ.not_seen_by_finance.order(:internal_deadline).load

  end

  def confirm
    params[:pq].each do |id, values|
      puts "#{id} ->  #{values}"
      seen_by_finance = values['seen_by_finance']
      finance_interest = values['finance_interest'] || false
      pq = PQ.find(id)
      pq.update(seen_by_finance: seen_by_finance, finance_interest: finance_interest)
    end


    flash[:notice] = 'Successfully register interest, in the questions'
    redirect_to action: 'questions'
  end

  protected

  def load_import_service(service = ImportService.new)
    @import_service ||= service
  end


end