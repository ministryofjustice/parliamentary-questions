class EarlyBirdSendEmailsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def send_emails
    service = EarlyBirdReportService.new
    service.notify_early_bird
    flash[:success] = t('page.flash.earlybird_sent')
    redirect_to controller: 'early_bird_members', action: 'index'
  end
end
