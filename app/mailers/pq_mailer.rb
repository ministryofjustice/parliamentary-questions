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

    @template_params = build_primary_hash(pq, ao)

    cc_list = [
        @template_params[:mpemail],
        @template_params[:policy_mpemail],
        @template_params[:press_email]
    ]

    cc_list.append(get_mp_office_email(pq, 'Simon Hughes (MP)'))

    # add the people from the Actionlist
    cc_list.append(get_action_list_mails)

    #add the Deputy director of the AO if they exist and have a mail.
    cc_list.append(get_dd_email(ao))

    # get the finance emails
    cc_list.append(finance_users_emails) if pq.finance_interest

    @template_params[:cc_list] = cc_list.reject(&:blank?).join(';')

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
    mail(to: @template_params[:email], cc: @template_params[:cc], subject: 'PQs allocated today')
  end

  private
  def build_primary_hash(pq,ao)
    {
      :ao_name => ao.name,
      :email => ao.emails,
      :uin => pq.uin,
      :question => pq.question,
      :mpname => pq.minister.nil? ? '' : pq.minister.name ,
      :mpemail => pq.minister.nil? ? '' : pq.minister.email,
      :policy_mpname => pq.policy_minister.nil? ? '' :  pq.policy_minister.name,
      :policy_mpemail => pq.policy_minister.nil? ? '' :  pq.policy_minister.email,
      :press_email => ao.press_desk.nil? ? '' : ao.press_desk.email_output,
      :member_name => pq.member_name.nil? ? '' : pq.member_name,
      :house_name => pq.house_name.nil? ? '' : pq.house_name,
      :internal_deadline => pq.internal_deadline.nil? ? '' : "#{pq.internal_deadline.strftime('%d/%m/%Y') } - 10am "
    }
  end

  def get_mp_office_email(pq, mp_name)
    # add the mp_cc_list if the minister is 'Simon Hughes'
    if !pq.minister.nil? && pq.minister.name == mp_name
      return [
          'Christopher.Beal@justice.gsi.gov.uk',
          'Nicola.Calderhead@justice.gsi.gov.uk',
          'thomas.murphy@JUSTICE.gsi.gov.uk'
      ]
    end
  end
  def get_action_list_mails
    ActionlistMember.where('deleted = false').collect{|it| it.email}
  end
  def finance_users_emails
    User.where("roles = 'FINANCE'").where('is_active = TRUE').collect{|it| it.email}
  end
  def get_dd_email(ao)
    if !ao.deputy_director.nil?
      if !ao.deputy_director.email.nil?
        return ao.deputy_director.email
      end
    end
  end
end
