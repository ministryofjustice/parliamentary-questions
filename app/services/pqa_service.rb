class PQAService
  def self.from_settings
    new(PQA::ApiClient.from_settings)
  end

  def initialize(client)
    @client = client
  end

  def questions(date_from, date_to = nil, status = nil)
    response = @client.questions(date_from, date_to, status)
    PQA::XmlDecoder.decode_questions(response.body)
  end

  def question(uin)
    response = @client.question(uin)
    PQA::XmlDecoder.decode_questions(response.body)
  end

  def answer_response(uin, member_id, text, is_holding_answer)
    answer                   = PQA::Answer.new
    answer.minister_id       = member_id
    answer.text              = text
    answer.is_holding_answer = is_holding_answer
    response                 = @client.save_answer(uin, PQA::XmlEncoder.encode_answer(answer))

    PQA::XmlDecoder.decode_answer_response(response.body)
  end
end
