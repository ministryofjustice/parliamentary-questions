class WatchlistSendEmailsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def send_emails
    service = WatchlistReportService.new
    service.notify_watchlist
    flash[:success] = t('page.flash.watchlist_email_sent')
    redirect_to controller: 'watchlist_members', action: 'index'
  end
end
