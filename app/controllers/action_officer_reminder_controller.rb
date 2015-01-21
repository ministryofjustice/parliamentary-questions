class ActionOfficerReminderController  < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_data

  def accept_reject
    LogStuff.tag(:mailer_remind) do
      PqMailer.acceptance_reminder_email(@template).deliver
    end

    @ao_pq.increment(:reminder_accept).save()

    flash[:reminder] = "reminder sent"
    render partial: 'shared/flash_messages'
  end

  def send_draft
    LogStuff.tag(:mailer_accept) do
      PqMailer.acceptance_email(@pq, @ao, true).deliver
    end

    @ao_pq.increment(:reminder_draft).save()

    flash[:reminder] = "reminder sent"
    render partial: 'shared/flash_messages'
  end

private

  def set_data
    id = params[:id]
    @ao_pq = ActionOfficersPq.find(id)
    @pq = Pq.find(@ao_pq.pq_id)
    @ao = ActionOfficer.find(@ao_pq.action_officer_id)

    @template = Hash.new
    @template[:ao_name] = @ao.name
    @template[:email] = @ao.emails
    @template[:uin] = @pq.uin
    @template[:question] = @pq.question
    @template[:member_name] = @pq.member_name
    @template[:house] = @pq.house_name
  end
end
