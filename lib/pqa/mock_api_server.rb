require 'sinatra/base'
require 'date'

module PQA
  class MockApiServer < Sinatra::Base
    def initialize(path = nil)
      schema_path = path || File.expand_path('schema.xsd', __dir__)
      @schema     = Nokogiri::XML::Schema(File.read(schema_path))
      @questions  = {}
      super(nil)
    end

    get '/' do
      'This API is working'
    end

    put '/reset' do
      @questions = {}
      "ok"
    end

    put '/api/qais/questions/:uin' do
      xml    = request.body.read
      doc    = Nokogiri::XML(xml)
      errors = @schema.validate(doc)
      q      = QuestionParser.new(xml).question

      unless errors.empty?
        status 400
        msg = (
          ["Invalid XML message"] + 
          errors.map { |err| "- #{err.inspect}" }
        ).join("\n")
        body msg
      else
        @questions[q.uin] = q
        body "Uin: #{q.uin}, tabled date: #{q.tabled_date}, status: #{q.question_status} => OK"
      end
    end

    put '/api/qais/answers/:uin' do
      answer = Answer.new
      answer.preview_url = "https://wqatest.parliament.uk/Questions/Details/#{params[:uin]}"
      XMLEncoder.encode_answer_response(answer)
    end

    delete '/api/qais/questions/:uin' do
      uin = params[:uin]
      @questions.delete(uin)
      "ok"
    end

    get '/api/qais/questions' do
      status       = params[:status]
      date_from    = DateTime.parse(params[:dateFrom] || DateTime.commercial(1000).to_s)
      date_to      = DateTime.parse(params[:dateTo]   || DateTime.commercial(3000).to_s)
      match_status = proc { |q| !status || q.question_status == status }
      questions    = @questions.select do |uin, q|
        q.tabled_date >= date_from && q.tabled_date <= date_to && match_status.call(q)
      end.values

      XMLEncoder.encode_questions(questions)
    end
  end
end
