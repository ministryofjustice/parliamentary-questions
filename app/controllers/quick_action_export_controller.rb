class QuickActionExportController < ApplicationController
  before_action :authenticate_user!, PqUserFilter

  def new
    form = QuickActionExport.new(quick_action_export_params)
    @pqs_comma_separated = params[:pqs_comma_separated]
    @total_pqs = params[:total_pqs]
    @total_pqs = form.total_pqs unless form.total_pqs.nil?

    if form.valid?
      @total_pqs = form.total_pqs
      Rails.logger.debug "total pqs = " || @total_pqs.to_s

      if @pqs_comma_separated.nil?
        @total_pqs = 0
      else

        @quick_actions_service = QuickActionsService.new
        pqs_array = @quick_actions_service.valid_pq_list(@pqs_comma_separated)

        @total_pqs = pqs_array.count

        send_data(pqs_array.to_csv, content_type: "text/csv")

      end

      # 200
    else
      Rails.logger.debug "form invalid"
      flash[:error] = "Form was not completed"
      status = 400
      400
    end

    flash.now[:error] =
      case status
      when 400
        "Error in establishing export"
      end

    render(partial: "dashboard/quick_action_export",
           locals: { total_pqs: @total_pqs, pqs_comma_separated: @pqs_comma_separated },
           status:)
  end

  def export
    Rails.logger.debug "Im in the export"

    render(partial: "dashboard/quick_action_export",
           locals: { total_pqs: @total_pqs, pqs_comma_separated: @pqs_comma_separated },
           status:)
  end

private

  def quick_action_export_params
    # params.require(:quick_action_export).permit(:total_pqs, :pqs_comma_separated)
    params.permit(:total_pqs, :pqs_comma_separated)
  end

  def run_export(export_type, _template)
    my_export = export_type.new(pqs_array)
    send_data(my_export.to_csv, content_type: "text/csv")
  end
end
