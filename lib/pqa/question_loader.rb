module PQA
  class QuestionLoader
    def initialize
      uri     = "http://#{MockApiServerRunner::HOST}:#{MockApiServerRunner::PORT}"
      @client = ApiClient.new(uri, nil, nil, nil)
    end

    def load_and_import(end = 1, skip_import = false)
      import    = Import.new
      questions =
        (1..end).map do |i|
          QuestionBuilder.default("uin-#{i}")
        end
      load(questions)
      unless skip_import
        import.run(Date.yesterday, Date.tomorrow)
        questions
      end
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
