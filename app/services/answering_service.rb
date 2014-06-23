class AnsweringService

  def initialize(questionsService = QuestionsService.new)
    @questionsService = questionsService
  end


  def answer(pq, args)
    uin = pq.uin
    if pq.minister.nil?
      raise 'Replying minister is not selected for the question'
    end
    if pq.minister.member_id.nil?
      raise 'Replying minister has not member id, please update the member id of the minister'
    end

    member_id = pq.minister.member_id
    text = args[:text]
    is_holding_answer = args[:is_holding_answer] || false

    result = @questionsService.answer(uin: uin, member_id: member_id, text: text, is_holding_answer: is_holding_answer)
    if !result[:error].nil?
      raise result[:error]
    end
    preview_url = result[:preview_url]
    # update the preview url
    pq.update(preview_url: preview_url)

  end

end