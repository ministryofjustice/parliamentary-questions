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

        @pqs_comma_separated.split(',').map { |p|
          if Pq.find_by(uin: p).nil?
            errors.add(p, "False PQ UIN")
            return false
          else
            x = Pq.find_by(uin: p)
            pqs_array.push(x)
          end
        }
        @total_pqs = pqs_array.count
        total_pqs = @total_pqs

        send_data(pqs_array.to_csv, content_type: 'text/csv')

        #run_export(Export::PqSelection, 'index')

      end

      #200
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
    params.permit(:total_pqs, :pqs_comma_separated, :utf8, :authenticity_token, :date_from, :date_to)

    render(partial: 'dashboard/quick_action_export',
           locals:  { total_pqs: @total_pqs, pqs_comma_separated: @pqs_comma_separated },
           status:  status)

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
