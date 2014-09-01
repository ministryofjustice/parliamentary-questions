class PqMailer < PQBaseMailer
  default from: Settings.mail_from

  def commission_email(template_params)
  	@template_params = template_params

  	# email, name from AO
  	# uin, question from PQ
  	# url with the token
    mail(to: @template_params[:email], subject: "You have been allocated PQ #{@template_params[:uin]}")
  end

  def notify_dd_email(template_params)
    @template_params = template_params
    mail(to: @template_params[:email], subject: "#{@template_params[:ao_name]} has been allocated PQ #{@template_params[:uin]}")
  end

  def acceptance_email(pq, ao, urgent = false)

    @template_params = Hash.new
    @template_params[:ao_name] = ao.name
    @template_params[:email] = ao.emails
    @template_params[:uin] = pq.uin
    @template_params[:question] = pq.question
    @template_params[:mpname] = pq.minister.name unless pq.minister.nil?
    @template_params[:mpemail] = pq.minister.email unless pq.minister.nil?
    @template_params[:policy_mpname] = pq.policy_minister.name unless pq.policy_minister.nil?
    @template_params[:policy_mpemail] = pq.policy_minister.email unless pq.policy_minister.nil?
    @template_params[:press_email] = ao.press_desk.email_output unless ao.press_desk.nil?
    @template_params[:member_name] = pq.member_name unless pq.member_name.nil?
    @template_params[:house_name] = pq.house_name unless pq.house_name.nil?
    @template_params[:internal_deadline] = "#{pq.internal_deadline.strftime('%d/%m/%Y') } - 10am " unless pq.internal_deadline.nil?


    mp_cc_list = [
        'Christopher.Beal@justice.gsi.gov.uk',
        'Nicola.Calderhead@justice.gsi.gov.uk',
        'thomas.murphy@JUSTICE.gsi.gov.uk'
    ]

    cc_list = [
        @template_params[:mpemail],
        @template_params[:policy_mpemail],
        @template_params[:press_email]
    ]

    # add the mp_cc_list if the minister is 'Simon Hughes'
    if !pq.minister.nil? && pq.minister.name == 'Simon Hughes'
      cc_list.append(mp_cc_list)
    end

    # add the people from the Actionlist
    action_list_emails = ActionlistMember.where('deleted = false').collect{|it| it.email}
    cc_list.append(action_list_emails)

    #add the Deputy director of the AO if they exist and have a mail.
    if !ao.deputy_director.nil?
      if !ao.deputy_director.email.nil?
       cc_list.append(ao.deputy_director.email)
      end
    end

    if pq.finance_interest
      finance_users_emails = User.where("roles = 'FINANCE'").where('is_active = TRUE').collect{|it| it.email}
      cc_list.append(finance_users_emails)
    end

    @template_params[:cc_list] = cc_list.join(';')

    if urgent
      subject = "URGENT : please send your draft response for PQ #{@template_params[:uin]}"
    else
      subject = "You have accepted PQ #{@template_params[:uin]}"
    end

    # email, name from AO
    # uin, question from PQ
    mail(to: @template_params[:email], subject: subject)
  end

  def acceptance_reminder_email(template_params)
    @template_params = template_params
    #template[:ao_name] = ao.name
    #template[:email] = ao.email
    #template[:uin] = pq.uin
    #template[:question] = pq.question
    mail(to: @template_params[:email], subject: "URGENT: you need to accept or reject PQ #{@template_params[:uin]}")
  end

  def watchlist_email(template_params)

    @template_params = template_params
    # email, name, token, entity
    date = Date.today.strftime('%d/%m/%Y')
    @template_params[:date] = date
    mail(to: @template_params[:email], subject: 'PQs allocated today')
  end
end
