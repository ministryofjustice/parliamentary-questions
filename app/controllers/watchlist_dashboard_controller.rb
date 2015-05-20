class WatchlistDashboardController < ApplicationController
  before_action AOTokenFilter, only: [:index]
  before_action :authenticate_user!, PQUserFilter, only: [:preview]

  def index
  	update_page_title('Watchlist preview')
    token = Token.entity(watchlist_params[:entity])
    token.accept unless token.acknowledged?
    @questions = Pq.allocated_since(DateTime.now.at_beginning_of_day)
  end

  def preview
    index
    render 'index'
  end

  private

  def watchlist_params
    params.permit(:entity)
  end
end
