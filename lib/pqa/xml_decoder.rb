module PQA
  module XMLDecoder
    module_function

    def decode_answer_response(xml)
      doc = parse_doc(xml)
      AnswerResponse.from_xml(doc.at('AnswerResponse'))
    end

    def decode_question(xml)
      decode_questions(xml).first
    end

    def decode_questions(xml)
       parse_doc(xml).xpath('//Question').map do |el|
        Question.from_xml(el)
      end
    end

    def parse_doc(xml)
      doc = Nokogiri::XML(xml)
      doc.remove_namespaces!
      doc
    end
  end
end
