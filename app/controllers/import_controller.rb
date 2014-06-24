class ImportController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :load_service

  def question
    import_result = @importService.questions_by_uin(params[:uin])
    @questions = import_result[:questions]
    @errors = import_result[:errors]

    render :partial => 'questions_import'
  end

  def questions
    dateTo = DateTime.parse(params[:dateTo])
    dateFrom = DateTime.parse(params[:dateFrom])
    import_result = @importService.questions(dateFrom: dateFrom, dateTo: dateTo)

    @questions = import_result[:questions]
    @errors = import_result[:errors]

    render :partial => 'questions_import'
  end

  protected

  def load_service(importService = ImportService.new)
    @importService ||= importService
  end
end