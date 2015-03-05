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

  def acceptance_email(pq, ao)
    @template_params =
      build_primary_hash(pq, ao)
        .merge(cc_list: cc_list(pq, ao))

    mail(to: @template_params[:email], subject: "You accepted PQ #{@template_params[:uin]}")
  end

  def acceptance_reminder_email(ao, pq)
    @template_params = build_primary_hash(pq, ao)
    mail(to: @template_params[:email], subject: "URGENT REMINDER: you need to accept or reject PQ #{@template_params[:uin]}")
  end

  def draft_reminder_email(ao, pq)
    @template_params =
      build_primary_hash(pq, ao)
        .merge(cc_list: cc_list(pq, ao))

    mail(to: @template_params[:email], subject: "URGENT REMINDER: please send your draft response to PQ #{@template_params[:uin]}")
  end

  def watchlist_email(template_params)
    @template_params        = template_params
    @template_params[:date] = Date.today.to_s(:date)
    mail(to: @template_params[:email], cc: @template_params[:cc], subject: 'PQs allocated today')
  end

  def import_fail_email(params)
    @params = params
    mail(to: Settings.mail_tech_support, subject: 'API import failed')
  end

  private

  def cc_list(pq, ao)
    deputy_director_email = ao.deputy_director && ao.deputy_director.email

    cc_list =
      Set.new([deputy_director_email]) +
      mp_emails(pq) +
      policy_mpemails(pq) +
      action_list_emails +
      finance_users_emails(pq) +
      press_emails(ao)

    cc_list
      .reject(&:blank?)
      .join(';')
  end

  def mp_emails(pq)
    Array(pq.minister && pq.minister.contact_emails)
  end

  def policy_mpemails(pq)
    Array(pq.policy_minister && pq.policy_minister.contact_emails)
  end

  def press_emails(ao)
    Array(ao.press_desk && ao.press_desk.press_officer_emails)
  end

  def build_primary_hash(pq, ao)
    {
      ao_name:              ao.name,
      email:                ao.emails,
      uin:                  pq.uin,
      question:             pq.question,
      answer_by:            pq.minister && pq.minister.name,
      policy_mpname:        pq.policy_minister && pq.policy_minister.name,
      policy_mpemail:       policy_mpemails(pq).join(';'),
      press_email:          press_emails(ao).join(';'),
      mpemail:              mp_emails(pq).join(';'),
      member_name:          pq.member_name,
      member_constituency:  pq.member_constituency,
      house_name:           pq.house_name,
      internal_deadline:    format_internal_deadline(pq),
      date_to_parliament:   pq.date_for_answer.try(:to_s, :date),
      finance_users_emails: finance_users_emails(pq).join(';'),
    }
  end

  def action_list_emails
    ActionlistMember.where('deleted = false').map { |a| a.email }
  end

  def finance_users_emails(pq)
    if pq.finance_interest
      User.finance.where('email IS NOT NULL').map(&:email)
    else
      []
    end
  end

  def format_internal_deadline(pq)
    pq.internal_deadline ? "#{pq.internal_deadline.to_s(:date) } - 10am " : ''
  end
end
