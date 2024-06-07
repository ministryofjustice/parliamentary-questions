module PQA
  class AnswerResponse
    attr_accessor :preview_url

    def self.from_xml(element)
      a = new
      a.preview_url = XmlExtractor.text(element, "AnswerPreviewUrl")
      a
    end
  end
end
