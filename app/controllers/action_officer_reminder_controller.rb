class ActionOfficerReminderController  < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def accept_reject
    loading_records do |pq, ao, ao_pq|
      PqMailer.acceptance_reminder_email({
        ao_name:  ao.name,
        email:  ao.emails,
        uin:  pq.uin,
        question:  pq.question,
        member_name:  pq.member_name,
        answer_by:  pq.minister.name,
        house_name:  pq.house_name
      }).deliver

      ao_pq.increment(:reminder_accept).save()

      flash[:success] = "reminder sent"
      render partial: 'shared/flash_messages'
    end
  end

  def send_draft
    loading_records do |pq, ao, ao_pq|
      PqMailer.draft_reminder_email(ao, pq).deliver

      ao_pq.increment(:reminder_draft).save()

      flash[:success] = "reminder sent"
      render partial: 'shared/flash_messages'
    end
  end

  private

  def loading_records
    ao_pq = ActionOfficersPq.find(params[:id])
    yield(ao_pq.pq, ao_pq.action_officer, ao_pq)
  end
end
