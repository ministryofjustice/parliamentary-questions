require "sinatra/base"
require "active_support/all"

module PQA
  # This class provides a mock implementation of the PQ&A API.
  # It is used in development and testing only, and does not gets executed in
  # the production environment.
  class MockApiServer < Sinatra::Base
    SCHEMA_PATH      = File.expand_path("resources/schema.xsd", __dir__)
    SCHEMA           = Nokogiri::XML::Schema(File.read(SCHEMA_PATH))
    QUESTIONS        = {} # rubocop:disable Style/MutableConstant
    configure do
      set :lock, true
    end

    # NOTE: Internal to the Mock API server
    get "/" do
      "This API is working"
    end

    # NOTE: Internal to the Mock API server
    put "/reset" do
      QUESTIONS.clear
      "ok"
    end

    # NOTE: Internal to the Mock API server
    put "/api/qais/questions/:uin" do
      xml    = request.body.read
      doc    = Nokogiri::XML(xml)
      errors = SCHEMA.validate(doc)
      q      = XMLDecoder.decode_question(xml)

      if errors.empty?
        QUESTIONS[q.uin] = q
        body "Uin: #{q.uin}, tabled date: #{q.tabled_date}, status: #{q.question_status} => OK"
      else
        status 400
        msg = (
          ["Invalid XML message"] +
          errors.map { |err| "- #{err.inspect}" }
        ).join("\n")
        body msg
      end
    end

    put "/api/qais/answers/:uin" do
      answer = Answer.new
      answer.preview_url = "https://wqatest.parliament.uk/Questions/Details/#{params[:uin]}"
      XMLEncoder.encode_answer_response(answer)
    end

    get "/api/qais/questions" do
      status       = params[:status]
      date_from    = Time.zone.parse(params[:dateFrom] || Time.commercial(1000).to_s)
      date_to      = Time.zone.parse(params[:dateTo]   || Time.commercial(3000).to_s)

      match_status = proc { |q| !status || q.question_status == status }
      questions    = QUESTIONS.select { |_uin, q|
        q.tabled_date >= date_from && q.tabled_date <= date_to && match_status.call(q)
      }.values

      XMLEncoder.encode_questions(questions)
    end

    get "/api/qais/questions/:uin" do
      my_uin = QUESTIONS[params["uin"]]
      if my_uin.nil?
        "Not found"
      else
        XMLEncoder.encode_questions([my_uin])
      end
    end
  end
end
