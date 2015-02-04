class AnsweringService
  def initialize
    @pqa_service = PQAService.from_settings
  end

  def answer(pq, args)
    unless pq.minister && pq.minister.member_id
      raise 'Replying minister is not selected for the question, or does not have a member id'
    end

    uin               = pq.uin
    member_id         = pq.minister.member_id
    text              = args[:text]
    is_holding_answer = args[:is_holding_answer] || false
    answer_response   = @pqa_service.answer(uin, member_id, text, is_holding_answer)

    pq.update(preview_url: answer_response.preview_url)
  end
end
