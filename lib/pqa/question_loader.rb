module PQA
  class QuestionLoader
    def initialize
      uri     = "http://#{MockApiServerRunner::HOST}:#{MockApiServerRunner::PORT}"
      @client = ApiClient.new(uri, nil, nil)
    end

    def load(questions)
      @client.reset_mock_data!
      questions.each do |q|
        xml = XMLEncoder.encode_questions([q])
        @client.save_question(q.uin, xml)
      end
    end
  end
end
