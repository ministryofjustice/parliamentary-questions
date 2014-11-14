class MembersHttpClient
  def initialize(base_url = Settings.members_api_url)
    @base_url = base_url
    @client = HTTPClient.new
  end

  def members_xml(name)
    param = URI.escape("name*#{name}")
    endpoint = URI::join(@base_url, "/membersdataplatform/services/mnis/members/query/#{param}/")

    response = @client.get(endpoint)
    response.content
  end

  def members(name)
    XmlParse.get_xml_data(members_xml(name),'Member')
  end
end
