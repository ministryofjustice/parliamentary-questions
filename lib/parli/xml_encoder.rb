module Parli
  module XMLEncoder
    module_function

    def encode_member(m)
      Nokogiri::XML::Builder.new { |x|
        x.Members('Member_Id' => m.member_id) {
          x.displayAs m.display_as
        }
      }
    end
  end
end
