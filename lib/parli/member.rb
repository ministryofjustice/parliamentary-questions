module Parli
  class Member
    attr_accessor :member_id
    attr_accessor :display_as

    def self.from_xml(el)
      xml          = ::XMLExtractor
      m            = new
      m.member_id  = el.attr('Member_Id')
      m.display_as = xml.text(el, 'DisplayAs')
      m
    end
  end
end
