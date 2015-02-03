module PQA
  class QuestionLoader
    def initialize(client = nil)
      @client = client || ApiClient.from_settings
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
