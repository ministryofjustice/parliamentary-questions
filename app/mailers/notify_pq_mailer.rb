class NotifyPqMailer < GovukNotifyRails::Mailer
  # Typically we put varibales in alphabetically order, however in this file they
  # are in the same order as in the emails to prevent missing a variable which
  # can cause emails to not send

  # TODO: who do all these emails go to? always the action officer

  def acceptance_email(pq:, action_officer:)
    set_template('b8b325ad-a00a-4ae9-8830-6386f04adbca')
    set_personalisation(
      uin: pq.uin,
      ao_name: action_officer.name,
      question: pq.question,
      member_name: member_name_text(pq) || '',
      house_name: pq.house_name || '',
      member_constituency: member_constituency_text(pq) || '',
      answer_by: pq.minister&.name || '',
      internal_deadline: internal_deadline_text(pq) || '',
      date_to_parliament: date_to_parliament_text(pq) || '',
      cc_list: action_officer.group_email || '',
      mail_reply_to: Settings.mail_reply_to
    )
    mail(to: action_officer.email)
  end

  def acceptance_reminder_email(pq:, action_officer:)
    set_template('930fb678-0ecf-477c-9d2e-c63e101fcbc4')
    set_personalisation(
      uin: pq.uin,
      ao_name: action_officer.name,
      question: pq.question,
      member_name: member_name_text(pq) || '',
      house_name: pq.house_name || '',
      member_constituency: member_constituency_text(pq) || '',
      answer_by: pq.minister&.name || '',
      internal_deadline: internal_deadline_text(pq) || '',
      date_to_parliament: date_to_parliament_text(pq) || '',
      mail_reply_to: Settings.mail_reply_to
    )
    mail(to: action_officer.email)
  end

  def commission_email(pq:, action_officer:, token:, entity:)
    set_template('93cb8968-bd2a-401b-8b59-47f8e0b30ca0')
    set_personalisation(
      uin: pq.uin,
      ao_name: action_officer.name,
      question: pq.question,
      member_name: member_name_text(pq) || '',
      house_name: pq.house_name || '',
      member_constituency: member_constituency_text(pq) || '',
      answer_by: pq.minister&.name || '',
      internal_deadline: internal_deadline_text(pq) || '',
      date_to_parliament: date_to_parliament_text(pq) || '',
      pq_link: assignment_url(uin: pq.uin, token: token, entity: entity),
      mail_reply_to: Settings.mail_reply_to
    )
    mail(to: action_officer.email)
  end

  def draft_reminder_email(pq:, action_officer:)
    set_template('a194ce43-dfe4-4a4f-8f15-8ad2545c4fb9')
    set_personalisation(
      uin: pq.uin,
      ao_name: action_officer.name,
      question: pq.question,
      member_name: member_name_text(pq) || '',
      house_name: pq.house_name || '',
      member_constituency: member_constituency_text(pq) || '',
      answer_by: pq.minister&.name || '',
      date_to_parliament: date_to_parliament_text(pq) || '',
      internal_deadline: internal_deadline_text(pq) || '',
      cc_list: action_officer.group_email || '',
      finance_users_emails: finance_users_emails(pq),
      press_email: press_emails(action_officer),
      mail_reply_to: Settings.mail_reply_to
    )
    mail(to: action_officer.email)
  end

  def early_bird_email(email:, token:, entity:)
    set_template('e0700ef3-8a63-4041-ae97-323a1e62272f')
    set_personalisation(
      formatted_date: (Time.zone.today.strftime '%d/%m/%Y'),
      early_bird_link: early_bird_dashboard_url(token: token, entity: entity),
      reply_to_email: Settings.mail_reply_to
    )
    mail(to: email)
  end

  def watchlist_email(email:, token:, entity:)
    set_template('b452ebb8-c49e-46f6-9da5-3ba28b494ed6')
    set_personalisation(
      date_today: (Time.zone.today.strftime '%d/%m/%Y'),
      watch_list_url: watchlist_dashboard_url(token: token, entity: entity),
      mail_reply_to: Settings.mail_reply_to
    )
    mail(to: email)
  end

  private

  # Lets put these in a presenter thing!

  def answer_by_text(pq)
    "To be answered by: #{pq.minister&.name}" if pq.minister.present?
  end

  def member_name_text(pq)
    "Asked by #{pq.member_name}" if pq.member_name.present?
  end

  def member_constituency_text(pq)
    "Constituency #{pq.member_constituency}" if pq.member_constituency.present?
  end

  def internal_deadline_text(pq)
    "The internal deadline is: #{format_internal_deadline(pq)}" if pq.internal_deadline.present?
  end

  def date_to_parliament_text(pq)
    'Due back to Parliament ' + pq.date_for_answer.try(:to_s, :date) if pq.date_for_answer.present?
  end

  def format_internal_deadline(pq)
    pq.internal_deadline ? "#{pq.internal_deadline.to_s(:date)} - #{pq.internal_deadline.strftime('%I').to_i}#{pq.internal_deadline.strftime('%p').downcase} " : ''
  end

  def finance_users_emails(pq)
    if pq.finance_interest
      User.finance.where('email IS NOT NULL').map(&:email)
    else
      []
    end
  end

  def press_emails(ao)
    Array(ao.press_desk && ao.press_desk.press_officer_emails)
  end
end
