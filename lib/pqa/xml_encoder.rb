module PQA
  module XMLEncoder
    XML_NS    = {
      'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
      'xmlns'     => 'http://data.parliament.uk/QnA/2013/02'
    }
    module_function

    def encode_answer(answer)
      Nokogiri::XML::Builder.new { |x|
        x.Answer('xmlns' => 'http://data.parliament.uk/QnA/2013/02') {
          x.IsHoldingAnswer answer.is_holding_answer
          x.Text answer.text
          x.MinisterId answer.member_id
        }
      }.to_xml
    end

    def encode_answer_response(answer_response)
      Nokogiri::XML::Builder.new { |x|
        x.AnswerResponse(XML_NS) {
          x.AswerPreviewUrl answer_response.preview_url
        }
      }.to_xml
    end

    def encode_questions(questions)
      Nokogiri::XML::Builder.new do |x|
        x.Questions(XML_NS) do
          questions.each do |q|
            x.Question do
              x.Uin q.uin
              x.UpdatedDate q.updated_date.xmlschema
              x.AnsweringBody do
                x.AnsweringBodyName q.answering_body_name
                x.AnsweringBodyShortName q.answering_body_short_name
                x.AnsweringBodyId q.answering_body_id
              end
              x.House do
                x.HouseId q.house_id
                x.HouseName q.house_name
              end
              x.TablingMember do
                x.MemberId q.member_id
                x.MemberName q.member_name
                x.Constituency q.member_constituency
              end
              x.QuestionStatus q.question_status
              x.QuestionType q.question_type
              x.RegisteredInterest q.registered_interest
              x.Session q.session
              x.TabledDate q.tabled_date.to_date.iso8601
              x.DateForAnswer q.date_for_answer.to_date.iso8601
              x.Target q.target
              x.Text q.text
              x.VersionNumber q.version_number
              x.ParliamentNumber q.parliament_number
              x.SessionNumber q.session_number
            end
          end
        end
      end.to_xml
    end
  end
end
