class NotifyMailer < GovukNotifyRails::Mailer

# Typically we put varibales in alphabetically order, however in this file they
# are in the same order as in the emails to prevent missing a variable which
# can cause emails to not send

  def acceptance_email(pq:, action_officer:)
    set_template('b8b325ad-a00a-4ae9-8830-6386f04adbca')
    set_personalisation(
      uin: pq.uin,
      ao_name: action_officer.name,
      question: pq.question,
      member_name: pq.member_name,
      house_name: pq.house_name,
      member_constituency: pq.member_constituency,
      answer_by: pq.minister&.name,
      internal_deadline: format_internal_deadline(pq),
      date_to_parliament: pq.date_for_answer.try(:to_s, :date),
      cc_list: action_officer.group_email,
      mail_reply_to: Settings.mail_reply_to,
    )
    mail(to: '')
  end

  def acceptance_reminder_email(pq:, action_officer:)
    set_template('930fb678-0ecf-477c-9d2e-c63e101fcbc4')
    set_personalisation(
      uin: pq.uin,
      ao_name: action_officer.name,
      question: pq.question,
      member_name: pq.member_name,
      house_name: pq.house_name,
      member_constituency: pq.member_constituency,
      answer_by: pq.minister&.name,
      internal_deadline: format_internal_deadline(pq),
      date_to_parliament: pq.date_for_answer.try(:to_s, :date),
      mail_reply_to: Settings.mail_reply_to,
    )
    mail(to: '')
  end

  def commission_email(pq:, action_officer:, token:, entity:)
    set_template('93cb8968-bd2a-401b-8b59-47f8e0b30ca0')
    set_personalisation(
      uin: pq.uin,
      ao_name: action_officer.name,
      question: pq.question,
      member_name: pq.member_name,
      house_name: pq.house_name,
      member_constituency: pq.member_constituency,
      answer_by: pq.minister&.name,
      internal_deadline: format_internal_deadline(pq),
      date_to_parliament: pq.date_for_answer.try(:to_s, :date),
      pq_link: assignment_url(uin: pq.uin, token: token, entity: entity),
      mail_reply_to: Settings.mail_reply_to,
    )
    mail(to: ' ')
  end

  def draft_reminder_email(pq:, action_officer:)
    set_template('a194ce43-dfe4-4a4f-8f15-8ad2545c4fb9')
    set_personalisation(
      uin: pq.uin,
      ao_name: action_officer.name,
      question: pq.question,
      member_name: pq.member_name,
      house_name: pq.house_name,
      member_constituency: pq.member_constituency,
      answer_by: pq.minister&.name,
      date_to_parliament: pq.date_for_answer.try(:to_s, :date),
      internal_deadline: format_internal_deadline(pq),
      cc_list: action_officer.group_email,
      finance_users_emails: finance_users_emails(pq),
      press_email: press_emails(action_officer),
      mail_reply_to: Settings.mail_reply_to,
    )
    mail(to: ' ')
  end

  def early_bird_email(email:, token:, entity:)
    set_template('e0700ef3-8a63-4041-ae97-323a1e62272f')
    set_personalisation(
      formatted_date: (Date.today.strftime "%d/%m/%Y"),
      early_bird_link: early_bird_dashboard_url(token: token, entity: entity),
      reply_to_email: Settings.mail_reply_to,
    )
    mail(to: ' ')
  end

  def notify_dd_email(pq:, action_officer:)
    set_template('2876fe30-2231-4a60-8257-9dd1f4c3990a')
    set_personalisation(
      ao_name: action_officer.name,
      uin: pq.uin,
      dd_name: ao.deputy_director,
      question: pq.question,
      member_name: pq.member_name,
      house_name: pq.house_name,
      member_constituency: pq.member_constituency,
      answer_by: pq.minister&.name,
      date_to_parliament: pq.date_for_answer.try(:to_s, :date),
      internal_deadline: format_internal_deadline(pq),
      mail_reply_to: Settings.mail_reply_to,
    )
    mail(to: ' ')
  end

  def watchlist_email(email:, token:, entity:)
    set_template('b452ebb8-c49e-46f6-9da5-3ba28b494ed6')
    set_personalisation(
      date_today: (Date.today.strftime "%d/%m/%Y"),
      watch_list_url: watchlist_dashboard_url(token: token, entity: entity),
      mail_reply_to: Settings.mail_reply_to,
    )
    mail(to: ' ')
  end
end
