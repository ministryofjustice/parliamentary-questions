module Presenters
  module Email
    module_function

    def default_hash(pq, ao)
      {
        ao_name:              ao.name,
        email:                ao.email,
        cc:                   ao.group_email,
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

    def cc_list_hash(pq, ao)
      default_hash(pq, ao)
        .merge(cc_list: cc_list(pq, ao))
    end

    private_class_method

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


    def action_list_emails
      ActionlistMember.active.pluck(:email)
    end

    def finance_users_emails(pq)
      if pq.finance_interest
        User.finance.where('email IS NOT NULL').map(&:email)
      else
        []
      end
    end

    def format_internal_deadline(pq)
      pq.internal_deadline ? "#{pq.internal_deadline.to_s(:date) } - 11am " : ''
    end
  end
end
