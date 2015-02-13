class WatchlistSendEmailsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def send_emails
    service = WatchlistReportService.new
    service.notify_watchlist
    flash[:success] = 'An email with the allocation information has been sent to all of the watchlist members'
    redirect_to controller: 'watchlist_members', action: 'index'
  end
end
