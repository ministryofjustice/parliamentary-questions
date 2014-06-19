class MembersHttpClient

  def initialize(base_url = Settings.members_api_url)
    @base_url = base_url
    @client = HTTPClient.new
  end

  def members(name)
    param = URI.escape("name*#{name}")
    endpoint = URI::join(@base_url, "/membersdataplatform/services/mnis/members/query/#{param}/")
    puts endpoint
    response = @client.get(endpoint)
    response.content
  end
  #http://data.parliament.uk/membersdataplatform/services/mnis/members/query/name*Diane%20Abbott

end