module Unit
  module QuestionFactory
    def decode_csv(s)
      CSV.parse(s).drop(1)
    end

    def mk_pq(uin, h = {})
      default_h = {
        uin: uin,
        raising_member_id: 1,
        question: 'test question',
        tabled_date: Date.yesterday,
        answer_submitted: Date.today,
        draft_answer_received: Date.today,
      }

      Pq.create(default_h.merge(h))
    end
  end
end