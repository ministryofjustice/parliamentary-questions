class ActionOfficerReminderMailer < PQBaseMailer
  default from: Settings.mail_from
  def remind_accept_reject_email(template_params)
    @template_params = template_params

    #template[:name] = ao.name
    #template[:email] = ao.email
    #template[:uin] = pq.uin
    #template[:question] = pq.question
    mail(to: @template_params[:email], subject: "URGENT: you need to accept or reject PQ #{@template_params[:uin]}")
  end

end
