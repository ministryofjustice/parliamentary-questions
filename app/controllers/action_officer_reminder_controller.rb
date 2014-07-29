class ActionOfficerReminderController  < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_data

  def accept_reject
    ActionOfficerReminderMailer.remind_accept_reject_email(@template).deliver

    flash[:notice] = "A reminder email has been sent to #{@ao.emails}"
    render partial: 'shared/flash_messages'
  end

  def send_draft
    PQAcceptedMailer.commit_email(@pq, @ao, true).deliver

    flash[:notice] = "A reminder to send the draft has been sent to #{@ao.emails}"
    render partial: 'shared/flash_messages'
  end


  private

  def set_data
    id = params[:id]
    ao_pq = ActionOfficersPq.find(id)
    @pq = Pq.find(ao_pq.pq_id)
    @ao = ActionOfficer.find(ao_pq.action_officer_id)

    @template = Hash.new
    @template[:name] = @ao.name
    @template[:email] = @ao.emails
    @template[:uin] = @pq.uin
    @template[:question] = @pq.question
  end

end