class ActionOfficerReminderController  < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def accept_reject
    loading_records_and_rendering do |pq, ao, ao_pq|
      PqMailer.acceptance_reminder_email(ao, pq).deliver
      ao_pq.increment(:reminder_accept).save()
    end
  end

  def send_draft
    loading_records_and_rendering do |pq, ao, ao_pq|
      PqMailer.draft_reminder_email(ao, pq).deliver
      ao_pq.increment(:reminder_draft).save()
    end
  end

  private

  def loading_records_and_rendering
    ao_pq = ActionOfficersPq.find(params[:id])
    yield(ao_pq.pq, ao_pq.action_officer, ao_pq)
    flash[:success] = "reminder sent"
    render partial: 'shared/flash_messages'
  end
end
