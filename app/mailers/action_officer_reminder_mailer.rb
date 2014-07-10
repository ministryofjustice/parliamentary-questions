class ActionOfficerReminderMailer < PqBaseMailer
  default from: Settings.mail_from
  def remind_accept_reject_email(template_params)

    @template_params = template_params

    #template[:name] = ao.name
    #template[:email] = ao.email
    #template[:uin] = pq.uin
    #template[:question] = pq.question

    mail(to: @template_params[:email], subject: "[Parliamentary-Questions] URGENT: #{@template_params[:uin]} | You have to Accept or Reject the question")
  end

end
