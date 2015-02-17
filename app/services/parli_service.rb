class ParliService
  def initialize
    @client = Parli::ApiClient.from_settings
  end

  def members_by_name(name)
    resp = @client.members_by_name(name)
    Parli::XMLDecoder.decode_members(resp.body)
  end
end
