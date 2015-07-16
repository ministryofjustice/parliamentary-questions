class EarlyBirdSendEmailsController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def send_emails
    service = EarlyBirdReportService.new
    service.notify_earlybird
    flash[:success] = 'An email with the new questions information has been sent to all of the early bird members'
    redirect_to controller: 'early_bird_members', action: 'index'
  end
end
