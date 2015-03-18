class TransferredController < ApplicationController
  include Validators::DateInput

  before_action :authenticate_user!, PQUserFilter

  def new
    @ogd_list = Ogd.all
    @pq       = Pq.new
  end

  def create
    @pq       = Pq.new
    @ogd_list = Ogd.all

    with_valid_dates do
      if @pq.update(transferred_pq_params)
        flash[:success] = 'Transferred PQ was successfully created.'
        redirect_to dashboard_path
      else
        flash.now[:error] = 'There was an error creating the transfer PQ.'
        render :new
      end
    end
  end

  private

  def transferred_pq_params
    params
      .require(:pq)
      .permit(
        :uin,
        :question,
        :house_name,
        :member_name,
        :member_constituency,
        :date_for_answer,
        :registered_interest,
        :question_type,
        :transfer_in_ogd_id,
        :transfer_in_date
      )
      .merge({ 
        transferred:        true,
        raising_member_id:  '0',
        progress:           Progress.unassigned 
      })
  end

  def with_valid_dates
    [
      :date_for_answer,
      :transfer_in_date
    ].each { |date_key| parse_date(params[:pq][date_key]) }
    yield
    rescue DateTimeInputError
      flash.now[:error] = 'Invalid date input!'
      render(:new, status: 422)
  end
end
