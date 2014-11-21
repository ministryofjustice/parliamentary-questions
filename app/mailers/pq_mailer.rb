class PqMailer < PQBaseMailer
  default from: Settings.mail_from

  def commission_email(template_params)
  	@template_params = template_params

    mail(to: @template_params[:email], subject: "You have been allocated PQ #{@template_params[:uin]}")
  end

  def notify_dd_email(template_params)
    @template_params = template_params
    mail(to: @template_params[:email], subject: "#{@template_params[:ao_name]} has been allocated PQ #{@template_params[:uin]}")
  end

  def acceptance_email(pq, ao, urgent = false)

    @template_params = build_primary_hash(pq, ao)

    @template_params[:date_to_parliament] = pq.date_for_answer.try(:to_s, :date)

    cc_list = [
        @template_params[:mpemail],
        @template_params[:policy_mpemail],
        @template_params[:press_email]
    ]

    cc_list.append(get_mp_office_email(pq, 'Simon Hughes (MP)'))

    cc_list.append(get_action_list_mails)

    cc_list.append(get_dd_email(ao))

    @template_params[:finance_users_emails] = finance_users_emails(pq)
    cc_list.append(@template_params[:finance_users_emails])

    @template_params[:cc_list] = cc_list.reject(&:blank?).join(';')

    if urgent
      subject = "URGENT : please send your draft response for PQ #{@template_params[:uin]}"
    else
      subject = "You have accepted PQ #{@template_params[:uin]}"
    end

    mail(to: @template_params[:email], subject: subject)
  end

  def acceptance_reminder_email(template_params)
    @template_params = template_params
    mail(to: @template_params[:email], subject: "URGENT: you need to accept or reject PQ #{@template_params[:uin]}")
  end

  def watchlist_email(template_params)

    @template_params = template_params
    date = Date.today.to_s(:date)
    @template_params[:date] = date
    mail(to: @template_params[:email], cc: @template_params[:cc], subject: 'PQs allocated today')
  end

  def import_fail_email(params)
    @params = params
    mail(to: Settings.mail_tech_support, subject: 'API import failed')
  end

private

  def build_primary_hash(pq,ao)
    {
      :ao_name => ao.name,
      :email => ao.emails,
      :uin => pq.uin,
      :question => pq.question,
      :mpname => get_minister_detail(pq,'name') ,
      :mpemail => get_minister_email(pq.minister),
      :policy_mpname => get_policy_minister_detail(pq, 'name'),
      :policy_mpemail => get_minister_email(pq.policy_minister),
      :press_email => ao.press_desk.nil? ? '' : ao.press_desk.email_output,
      :member_name => get_pq_details(pq,'member_name'),
      :house_name => get_pq_details(pq,'house_name'),
      :internal_deadline => pq.internal_deadline.nil? ? '' : "#{pq.internal_deadline.to_s(:date) } - 10am "
    }
  end

  def get_minister_email(minister)
    minister.nil? ? '' : minister.email
  end

  def get_minister_detail(pq, field)
    if !pq.minister.nil?
      return pq.minister[field]
    else
      return ''
    end
  end

  def get_policy_minister_detail(pq, field)
    if !pq.policy_minister.nil?
      return pq.policy_minister[field]
    else
      return ''
    end
  end

  def get_pq_details(pq, field)
    pq[field].nil? ? '' : pq[field]
  end

  def get_mp_office_email(pq, mp_name)
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

  def finance_users_emails(pq)
    result = User.where("roles = 'FINANCE'").where(deleted: false).collect{|it| it.email}
    return pq.finance_interest ? result.reject(&:blank?).join(';') : ''
  end

  def get_dd_email(ao)
    if !ao.deputy_director.nil?
      if !ao.deputy_director.email.nil?
        return ao.deputy_director.email
      end
    end
  end
end
