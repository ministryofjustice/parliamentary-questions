class ActionOfficerReminderController < ApplicationController
  before_action :authenticate_user!

  def accept_reject
    loading_records_and_rendering do |pq, ao, ao_pq|
      if ao.group_email.present?
        NotifyPqMailer.acceptance_reminder_email(pq:, action_officer: ao, email: ao.group_email).deliver_later
      end
      NotifyPqMailer.acceptance_reminder_email(pq:, action_officer: ao, email: ao.email).deliver_later
      ao_pq.increment(:reminder_accept).save!
    end
  end

  def send_draft
    loading_records_and_rendering do |pq, ao, ao_pq|
      if ao.group_email.present?
        NotifyPqMailer.draft_reminder_email(pq:, action_officer: ao, email: ao.group_email).deliver_later
      end
      NotifyPqMailer.draft_reminder_email(pq:, action_officer: ao, email: ao.email).deliver_later
      ao_pq.increment(:reminder_draft).save!
    end
  end

private

  def loading_records_and_rendering
    ao_pq = ActionOfficersPq.find(params[:id])
    yield(ao_pq.pq, ao_pq.action_officer, ao_pq)
    flash[:success] = "reminder sent"
    render partial: "shared/flash_messages"
  end
end
