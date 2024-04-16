module Presenters
  module Email
  module_function

    def default_hash(parliamentary_question, action_officer)
      {
        answer_by: parliamentary_question.minister&.name,
        action_officer_name: action_officer.name,
        cc: action_officer.group_email,
        date_to_parliament: parliamentary_question.date_for_answer.try(:to_formatted_s, :date),
        email: action_officer.email,
        finance_users_emails: finance_users_emails(parliamentary_question).join(";"),
        house_name: parliamentary_question.house_name,
        internal_deadline: format_internal_deadline(parliamentary_question),
        member_constituency: parliamentary_question.member_constituency,
        member_name: parliamentary_question.member_name,
        mpemail: mp_emails(parliamentary_question).join(";"),
        policy_mpemail: policy_mpemails(parliamentary_question).join(";"),
        policy_mpname: parliamentary_question.policy_minister&.name,
        press_email: press_emails(action_officer).join(";"),
        question: parliamentary_question.question,
        uin: parliamentary_question.uin,
      }
    end

    def cc_list_hash(parliamentary_question, action_officer)
      default_hash(parliamentary_question, action_officer)
        .merge(cc_list: cc_list(parliamentary_question, action_officer))
    end

    def cc_list(parliamentary_question, action_officer)
      deputy_director_email = action_officer.deputy_director&.email

      cc_list =
        Set.new([deputy_director_email]) +
        mp_emails(parliamentary_question) +
        policy_mpemails(parliamentary_question) +
        action_list_emails +
        finance_users_emails(parliamentary_question) +
        press_emails(action_officer)

      cc_list
        .reject(&:blank?)
        .join(";")
    end

    def finance_list_hash(parliamentary_question)
      default_hash(parliamentary_question)
        .merge(finance_list: finance_list(parliamentary_question))
    end

    def finance_list(parliamentary_question)
      finance_list = finance_users_emails(parliamentary_question)
      if finance_list.empty?
        ["No Finance users have an interest in this question."]
      else
        finance_list.reject(&:blank?)
      end
    end

    # private_class_method

    def mp_emails(parliamentary_question)
      Array(parliamentary_question.minister && parliamentary_question.minister.contact_emails)
    end

    def policy_mpemails(parliamentary_question)
      Array(parliamentary_question.policy_minister && parliamentary_question.policy_minister.contact_emails)
    end

    def press_emails(action_officer)
      Array(action_officer.press_desk && action_officer.press_desk.press_officer_emails)
    end

    def action_list_emails
      ActionlistMember.active.pluck(:email)
    end

    def finance_users_emails(parliamentary_question)
      if parliamentary_question.finance_interest
        User.finance.where.not(email: nil).map(&:email)
      else
        []
      end
    end

    def format_internal_deadline(parliamentary_question)
      parliamentary_question.internal_deadline ? "#{parliamentary_question.internal_deadline.to_formatted_s(:date)} - #{parliamentary_question.internal_deadline.strftime('%I').to_i}#{parliamentary_question.internal_deadline.strftime('%p').downcase} " : ""
    end

    def answer_by_text(parliamentary_question)
      "To be answered by: #{parliamentary_question.minister&.name}" if parliamentary_question.minister.present?
    end

    def member_name_text(parliamentary_question)
      "Asked by #{parliamentary_question.member_name}" if parliamentary_question.member_name.present?
    end

    def member_constituency_text(parliamentary_question)
      "Constituency #{parliamentary_question.member_constituency}" if parliamentary_question.member_constituency.present?
    end

    def internal_deadline_text(parliamentary_question)
      "The internal deadline is: #{format_internal_deadline(parliamentary_question)}" if parliamentary_question.internal_deadline.present?
    end

    def date_to_parliament_text(parliamentary_question)
      "Due back to Parliament #{parliamentary_question.date_for_answer.try(:to_formatted_s, :date)}" if parliamentary_question.date_for_answer.present?
    end
  end
end
