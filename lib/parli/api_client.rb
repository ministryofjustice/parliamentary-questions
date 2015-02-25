module Parli
  # API client for UK Parliament's Member Data platform
  # See http://data.parliament.uk/membersdataplatform/
  class ApiClient < HTTPClient
    def self.from_settings
      new(Settings.members_api_url, nil, nil, nil)
    end

    def members_by_name(name)
      q   = URI.escape("name*#{name}")
      uri = URI.parse File.join(@base_url, "/membersdataplatform/services/mnis/members/query/#{q}/")
      issue_request(:get, uri)
    end
  end
end
