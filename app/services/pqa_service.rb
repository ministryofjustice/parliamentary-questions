class PQAService
  def self.from_settings
    new(Settings.pq_rest_api.url,
        Settings.pq_rest_api.username,
        Settings.pq_rest_api.password)
  end

  def initialize(base_url, username, password)
    @client = PQA::ApiClient.new(base_url, username, password)
  end

  # Performs an API call and returns a list of questions
  def questions(date_from, date_to = nil, status = nil)
    $statsd.time("#{StatsHelper::IMPORT}.qa.response_time") do
      response = @client.questions(date_from, date_to, status)
      parser   = QuestionParser.new(response.body)
      parser.questions
    end
  end

  # Performs a API call and returns a preview URL for a question's answer
  def answer_preview_url(uin, member_id, text, is_holding_answer)
    answer                   = PQA::Answer.new
    answer.minister_id       = member_id
    answer.text              = text
    answer.is_holding_answer = is_holding_answer
    response                 = @client.save_answer(uin, XMLEncoder.encode_answer(answer))
    answer_response          = AnswerResponseParser.new(response.body).response
    answer_response.preview_url
  end
end
