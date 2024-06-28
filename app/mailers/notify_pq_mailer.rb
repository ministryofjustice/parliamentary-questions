require "resolv"

class NotifyPqMailer < ApplicationMailer
  include Presenters::Email

  # Typically we put variables in alphabetical order, however in this file they
  # are in the same order as in the emails to prevent missing a variable which
  # can cause emails to not send

  # rubocop:disable Naming/MethodParameterName
  def acceptance_email(pq:, action_officer:, email:)
    set_template("b8b325ad-a00a-4ae9-8830-6386f04adbca")
    set_personalisation(
      uin: pq.uin,
      ao_name: action_officer.name,
      question: pq.question,
      member_name: member_name_text(pq) || "",
      house_name: pq.house_name || "",
      member_constituency: member_constituency_text(pq) || "",
      answer_by: pq.minister&.name || "",
      internal_deadline: internal_deadline_text(pq) || "",
      date_to_parliament: date_to_parliament_text(pq) || "",
      cc_list: cc_list(pq, action_officer) || "",
      mail_reply_to: Settings.mail_reply_to,
    )
    set_email_reply_to(Settings.parliamentary_team_email)
    mail(to: email)
  end

  def acceptance_reminder_email(pq:, action_officer:, email:)
    set_template("930fb678-0ecf-477c-9d2e-c63e101fcbc4")
    set_personalisation(
      uin: pq.uin,
      ao_name: action_officer.name,
      question: pq.question,
      member_name: member_name_text(pq) || "",
      house_name: pq.house_name || "",
      member_constituency: member_constituency_text(pq) || "",
      answer_by: pq.minister&.name || "",
      internal_deadline: internal_deadline_text(pq) || "",
      date_to_parliament: date_to_parliament_text(pq) || "",
      mail_reply_to: Settings.mail_reply_to,
    )
    set_email_reply_to(Settings.parliamentary_team_email)
    mail(to: email)
  end

  def commission_email(pq:, action_officer:, token:, entity:, email:)
    check_is_wrong_domain(ActionMailer::Base.default_url_options[:host])

    set_template("93cb8968-bd2a-401b-8b59-47f8e0b30ca0")
    set_personalisation(
      uin: pq.uin,
      ao_name: action_officer.name,
      question: pq.question,
      member_name: member_name_text(pq) || "",
      house_name: pq.house_name || "",
      member_constituency: member_constituency_text(pq) || "",
      answer_by: pq.minister&.name || "",
      internal_deadline: internal_deadline_text(pq) || "",
      date_to_parliament: date_to_parliament_text(pq) || "",
      pq_link: assignment_url(host: ActionMailer::Base.default_url_options[:host], uin: pq.uin, token:, entity:, protocol: "https"),
      mail_reply_to: Settings.mail_reply_to,
    )
    set_email_reply_to(Settings.parliamentary_team_email)
    mail(to: email)
  end

  def draft_reminder_email(pq:, action_officer:, email:)
    set_template("a194ce43-dfe4-4a4f-8f15-8ad2545c4fb9")
    set_personalisation(
      uin: pq.uin,
      ao_name: action_officer.name,
      question: pq.question,
      member_name: member_name_text(pq) || "",
      house_name: pq.house_name || "",
      member_constituency: member_constituency_text(pq) || "",
      answer_by: pq.minister&.name || "",
      date_to_parliament: date_to_parliament_text(pq) || "",
      internal_deadline: internal_deadline_text(pq) || "",
      cc_list: cc_list(pq, action_officer) || "",
      press_email: press_emails(action_officer) || "",
      mail_reply_to: Settings.mail_reply_to,
    )
    set_email_reply_to(Settings.parliamentary_team_email)
    mail(to: email)
  end
  # rubocop:enable Naming/MethodParameterName

  def early_bird_email(email:, token:, entity:)
    set_template("e0700ef3-8a63-4041-ae97-323a1e62272f")
    set_personalisation(
      formatted_date: (Time.zone.today.strftime "%d/%m/%Y"),
      early_bird_link: early_bird_dashboard_url(host: ActionMailer::Base.default_url_options[:host], token:, entity:, protocol: "https"),
      reply_to_email: Settings.mail_reply_to,
    )
    set_email_reply_to(Settings.parliamentary_team_email)
    mail(to: email)
  end

  def watchlist_email(email:, token:, entity:)
    set_template("b452ebb8-c49e-46f6-9da5-3ba28b494ed6")
    set_personalisation(
      date_today: (Time.zone.today.strftime "%d/%m/%Y"),
      watch_list_url: watchlist_dashboard_url(token:, entity:, protocol: "https"),
      mail_reply_to: Settings.mail_reply_to,
    )
    set_email_reply_to(Settings.parliamentary_team_email)
    mail(to: email)
  end

private

  def check_is_wrong_domain(link_str)
    return if link_str == "127.0.0.1"

    if link_str.nil? || !!(link_str =~ Regexp.union([Resolv::IPv4::Regex, Resolv::IPv6::Regex]))
      raise "Got ip address, failed to get domain name, #{ENV['ENV']}, #{link_str}, #{ENV['SENDING_HOST']}"
    end
  end
end
