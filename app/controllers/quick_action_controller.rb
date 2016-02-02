class QuickActionController < ApplicationController

  before_action :authenticate_user!, PQUserFilter

  def new

    form = QuickActionExport.new(quick_action_export_params)
    @pqs_comma_separated = params[:pqs_comma_separated]
    @total_pqs = params[:total_pqs]
    @total_pqs = form.total_pqs unless form.total_pqs.nil?
    pqs_array = Array.new

    if form.valid?
      @total_pqs = form.total_pqs
      puts 'total pqs = ' || @total_pqs.to_s

      if @pqs_comma_separated.nil?
        @total_pqs = 0
      else

        @quick_actions_service  = QuickActionsService.new
        pqs_array = @quick_actions_service.valid_pq_list(@pqs_comma_separated)

        @total_pqs = pqs_array.count
        total_pqs = @total_pqs

        send_data(pqs_array.to_csv, content_type: 'text/csv')
      end
    else
      puts 'form invalid'
      flash[:error] = "Form was not completed"
      status = 400
      400
    end

    flash.now[:error] =
      case status
        when 400
          'Error in establishing export'
      end

    render(partial: 'dashboard/quick_action_export',
           locals:  { total_pqs: @total_pqs, pqs_comma_separated: @pqs_comma_separated },
           status:  status)
  end

  def export
    render(partial: 'dashboard/quick_action_export',
           locals:  { total_pqs: @total_pqs, pqs_comma_separated: @pqs_comma_separated },
           status:  status)
  end

  def dates
    params.permit(:total_pqs, :pqs_comma_separated, :utf8, :authenticity_token, :qa_edit_deadline_date, :qa_edit_draft_date, :qa_edit_pod_date, :qa_edit_minister_date, :qa_edit_answered_date)

    @quick_actions_service               = QuickActionsService.new
    @quick_actions_service.update_pq_list(params[:pqs_comma_separated], params[:qa_edit_deadline_date],params[:qa_edit_draft_date],params[:qa_edit_pod_date],params[:qa_edit_minister_date],params[:qa_edit_answered_date])

    flash[:Success] = "Question(s) updated with date(s)"
    redirect_to :back

  end

  private

  def quick_action_export_params
    #params.require(:quick_action_export).permit(:total_pqs, :pqs_comma_separated)
    params.permit(:total_pqs, :pqs_comma_separated)
  end

  def run_export(export_type, template)

    my_export = export_type.new(pqs_array)
    send_data(my_export.to_csv, content_type: 'text/csv')

  end


end
