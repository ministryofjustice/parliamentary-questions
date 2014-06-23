class AnsweringService

  def initialize(questionsService = QuestionsService.new)
    @questionsService = questionsService
  end


  def answer(pq, args)
    uin = pq.uin
    if pq.minister.nil?
      raise 'Minister can not be nil for the question'
    end
    if pq.minister.member_id.nil?
      raise 'Minister member_id can not be nil for the question'
    end

    member_id = pq.minister.member_id
    text = args[:text]
    is_holding_answer = args[:is_holding_answer] || false

    result = @questionsService.answer(uin: uin, member_id: member_id, text: text, is_holding_answer: is_holding_answer)
    preview_url = result[:preview_url]

    # update the preview url
    pq.update(answer_preview_url: preview_url)

  end

end