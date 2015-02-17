module PQA
  class AnswerResponse
    attr_accessor :preview_url
    def self.from_xml(el)
      a = new
      a.preview_url = XMLExtractor.text(el, 'AnswerPreviewUrl')
      a
    end
  end
end
