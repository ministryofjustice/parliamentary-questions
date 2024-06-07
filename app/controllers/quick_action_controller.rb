class QuickActionController < ApplicationController
  before_action :authenticate_user!, PqUserFilter

  def dates
    params.permit(:total_pqs, :pqs_comma_separated_for_dates, :utf8, :authenticity_token, :qa_edit_deadline_date, :qa_edit_draft_date, :qa_edit_pod_date, :qa_edit_minister_date, :qa_edit_answered_date)
    @quick_actions_service = QuickActionsService.new
    @quick_actions_service.update_pq_list(params[:pqs_comma_separated_for_dates], params[:qa_edit_deadline_date], params[:qa_edit_draft_date], params[:qa_edit_pod_date], params[:qa_edit_minister_date], params[:qa_edit_answered_date])
    flash[:Success] = "Date(s) updated"
    redirect_back fallback_location: root_path
  end

  def draft_reminders
    params.permit(:total_pqs, :pqs_comma_sep_for_drafts, :utf8, :authenticity_token)
    @quick_actions_service = QuickActionsService.new
    @quick_actions_service.mail_draft_list(params[:pqs_comma_sep_for_drafts])
    flash[:Success] = "Draft Reminder(s) Sent"
    redirect_back fallback_location: root_path
  end
end
