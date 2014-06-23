class MembersHttpClient

  def initialize(base_url = Settings.members_api_url)
    @base_url = base_url
    @client = HTTPClient.new
  end

  def members_xml(name)
    param = URI.escape("name*#{name}")

    # Example
    # http://data.parliament.uk/membersdataplatform/services/mnis/members/query/name*Diane%20Abbott
    endpoint = URI::join(@base_url, "/membersdataplatform/services/mnis/members/query/#{param}/")

    response = @client.get(endpoint)
    response.content
  end

  def members(name)
    parse_members_xml(members_xml(name))
  end


  def parse_members_xml(response)
    xml  = Nokogiri::XML(response)
    xml.remove_namespaces! # easy to parse if we are only using one namespace
    member_xml = xml.xpath('//Member')

    members = Array.new

    member_xml.each do |q|
      item = Hash.from_xml(q.to_xml)
      members.push(item["Member"])
    end
    members
  end

end