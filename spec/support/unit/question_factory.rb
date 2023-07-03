module Unit
  module QuestionFactory
    def mk_pq(uin, h = {})
      default_h = {
        uin:,
        raising_member_id: 1,
        question: "#{uin} body text",
        tabled_date: Date.yesterday,
        answer_submitted: Time.zone.today,
        draft_answer_received: Time.zone.today,
      }

      Pq.create!(default_h.merge(h))
    end
  end
end
