module XmlParse
  def get_xml_data(response,field_name)
    xml  = Nokogiri::XML(response)
    xml.remove_namespaces!
    matches= xml.xpath("//#{field_name}")

    output_array = Array.new

    matches.each do |q|
      item = Hash.from_xml(q.to_xml)
      output_array.push(item["#{field_name}"])
    end
    output_array
  end

  extend self
end
