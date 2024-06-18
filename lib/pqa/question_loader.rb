module PQA
  class QuestionLoader
    attr_reader :client

    def initialize
      uri = "http://#{MockApiServerRunner::HOST}:#{MockApiServerRunner::PORT}"
      @client = ApiClient.new(uri, nil, nil, nil)
    end

    def load_and_import(last_item = 1, skip_import: false)
      import = Import.new(@client)
      questions =
        (1..last_item).map do |i|
          QuestionBuilder.default("uin-#{i}")
        end
      load(questions)
      unless skip_import
        import.run(Date.yesterday, Date.tomorrow)
      end
      questions
    end

    def load(questions)
      @client.reset_mock_data!
      questions.each do |q|
        xml = XmlEncoder.encode_questions([q])
        @client.save_question(q.uin, xml)
      end
    end
  end
end
