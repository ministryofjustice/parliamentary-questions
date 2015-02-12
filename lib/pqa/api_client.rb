module PQA
  # API client for the Parlamentary Questions & Answer API
  #
  # Refer to the bundled XSD schema for details on payloads formats
  # (see 'lib/pqa/resources/schema.xsd').
  #
  class ApiClient < HTTPClient
    def self.from_settings
      new(Settings.pq_rest_api.host,
          Settings.pq_rest_api.username,
          Settings.pq_rest_api.password,
          File.expand_path('resources/certs/wqa.parliament.uk.pem', __dir__))
    end

    # Fetch parliamentary questions by date range and status.
    #
    # Note: Part of the actual PQ&A API
    #
    # @param date_from [Date]
    # @param date_to [Date]
    # @param status [String]
    #
    # @return [Net::HTTP::Response]
    def questions(date_from, date_to, status)
      uri       = URI.parse(File.join(@base_url, 'api/qais/questions'))
      params    = {
        'dateFrom' => date_from.xmlschema,
        'dateTo'   => date_to && date_to.xmlschema,
        'status'   => status
      }
      uri.query = URI.encode_www_form(params)
      issue_request(:get, uri.to_s)
    end

    # Loads a question in the Mock API server.
    #
    # Note: This is not part of the actual PQ&A API
    #
    # @param uin [String] An arbitrary UIN to be assigned to the question
    # @param xml [String] The XML representation of the question
    #
    # @return [Net::HTTP::Response]
    def save_question(uin, xml)
      uri = File.join(@base_url, 'api/qais/questions', uin)
      issue_request(:put, uri, xml)
    end

    # Saves a question answer.
    #
    # Note: This is part of the actual PQ&A API
    #
    # @param uin [String] The question unique identification number.
    # @param xml [String] The XML representation of the answer
    #
    # @return [Net::HTTP::Response]
    def save_answer(uin, xml)
      uri = File.join(@base_url, 'api/qais/answers', uin)
      issue_request(:put, uri, xml)
    end

    # Resets the Mock API in-memory data store.
    #
    # @return [Net::HTTP::Response]
    def reset_mock_data!
      uri = File.join(@base_url, 'reset')
      issue_request(:put, uri)
    end
  end
end
