class CommissionController < ApplicationController
  include Validators::DateInput

  before_action :authenticate_user!, PQUserFilter

  def commission
    pq     = Pq.find(params[:commission_form][:pq_id])
    
    status = checking_valid_dates do 
      form = CommissionForm.new(commission_form_params)
      if form.valid?
        CommissioningService.new.commission(form)
        200
      else
        400
      end
    end

    flash.now[:error] =
      case status
      when 400
         'Error in commissioning question' 
      when 422 
        'Invalid date input!'
      end

    render(partial: 'shared/question_assigned',
           locals:  { question: pq },
           status:  status)
  end

  def complete
    @pq = Pq.find_by(uin: params[:id])
    render :partial => 'shared/commissioned', :locals => {uin: @pq}
  end

  private

  def commission_form_params
    params.require(:commission_form)
      .permit(:pq_id, :minister_id, :policy_minister_id,
             { action_officer_id: [] },
             :date_for_answer, :internal_deadline)
  end

  def checking_valid_dates
    [
      :date_for_answer, 
      :internal_deadline
    ].each { |date_key| parse_date(params[:commission_form][date_key]) }
    yield
    rescue DateTimeInputError
      422
  end
end
