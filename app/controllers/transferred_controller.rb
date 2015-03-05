class TransferredController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def new
    loading_ogds do
      @pq = Pq.new
    end
  end

  def create
    loading_ogds do
      @pq = Pq.new(pq_params)

      if @pq.update(transferred: true,
                    raising_member_id: '0',
                    progress: Progress.unassigned)

        flash[:success] = 'Transferred PQ was successfully created.'
        redirect_to controller: 'dashboard', action: 'index'
      else
        flash[:error] = 'There was an error creating the transfer PQ.'
        render :new
      end
    end
  end

  private

  def pq_params
    params
      .require(:pq)
      .permit(:uin,
              :question,
              :house_name,
              :member_name,
              :member_constituency,
              :date_for_answer,
              :registered_interest,
              :question_type,
              :transfer_in_ogd_id,
              :transfer_in_date)
  end

  def loading_ogds
    @ogd_list = Ogd.all
    yield
  end
end
