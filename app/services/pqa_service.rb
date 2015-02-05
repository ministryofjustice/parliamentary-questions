class PQAService
  def self.from_settings
    new(PQA::ApiClient.from_settings)
  end

  def initialize(client)
    @client = client
  end

  def questions(date_from, date_to = nil, status = nil)
    $statsd.time("#{StatsHelper::IMPORT}.qa.response_time") do
      response = @client.questions(date_from, date_to, status)
      PQA::XMLDecoder.decode_questions(response.body)
    end
  end

  def answer_response(uin, member_id, text, is_holding_answer)
    answer                   = PQA::Answer.new
    answer.minister_id       = member_id
    answer.text              = text
    answer.is_holding_answer = is_holding_answer
    response                 = @client.save_answer(uin, PQA::XMLEncoder.encode_answer(answer))

    PQA::XMLDecoder.decode_answer_response(response.body)
  end
end
