module PQA
  class QuestionLoader
    def initialize(client, questions)
      @client    = client
      @questions = questions
    end

    def load
      @client.reset_mock_data!
      @questions.each do |q|
        xml = XMLEncoder.encode_questions([q])
        @client.save_question(q.uin, xml)
      end
    end
  end
end
