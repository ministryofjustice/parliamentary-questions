class WatchlistDashboardController < ApplicationController
  before_action AOTokenFilter, only: [:index]
  before_action :authenticate_user!, PQUserFilter, only: [:preview]

  def index

    at_beginning_of_day = DateTime.now.at_beginning_of_day
    allocated_today = ActionOfficersPq.where('updated_at >= ?', at_beginning_of_day)

    pq_ids = allocated_today.collect{|it| it.pq_id}

    @questions = PQ.where(id: pq_ids).load

  end

  def preview
    index
    render 'index'
  end
end
