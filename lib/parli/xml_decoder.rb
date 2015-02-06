module Parli
  module XMLDecoder
    module_function

    def decode_members(xml)
      doc = Nokogiri::XML(xml)
      doc.xpath('Members/Member').map do |el|
        Member.from_xml(el)
      end
    end
  end
end
