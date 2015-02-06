require 'net/https'
module PQA
  # API client for the Parlamentary Questions & Answer API
  #
  # Refer to the bundled XSD schema for details on payloads formats
  # (see 'lib/pqa/resources/schema.xsd').
  #
  class ApiClient
    PEM_FILE_PATH = File.expand_path('resources/certs/wqa.parliament.uk.pem', __dir__)

    def self.from_settings
      new(Settings.pq_rest_api.url,
          Settings.pq_rest_api.username,
          Settings.pq_rest_api.password)
    end

    def initialize(base_url, username, password)
      @base_url = base_url
      @username = username
      @password = password
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

    protected

    def issue_request(method, uri_s, body = nil)
      uri  = URI.parse(uri_s)
      req  = build_request(method, uri, body)
      http = handle_https(uri, Net::HTTP.new(uri.hostname, uri.port))
      res  = http.request(req)

      case res.code
      when /^2/
        res
      else
        msg = "PQ rest API responded with non success code: #{res.code}, response: #{res.body} (request: #{req.inspect})"
        LogStuff.error(msg)
        raise msg
      end
    rescue Net::ReadTimeout
      LogStuff.error "PQ rest api request timed out (request: #{req.inspect}, current timeout: #{req.read_timeout})"
      raise err
    rescue Errno::ECONNREFUSED => err
      LogStuff.error "PQ rest API refused HTTP connection"
      raise err
    end

    def handle_https(uri, http)
      if uri.scheme == 'https'
        http.use_ssl     = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        cert_dir = ENV['CA_CERT']

        if cert_dir && File.directory?(cert_dir)
          http.ca_path(cert_dir)
        else
          http.ca_file = PEM_FILE_PATH
        end
      end
      http
    end

    def build_request(method, uri, body)
      req = case method
            when :put
              r = Net::HTTP::Put.new(uri)
              r.body = body
              r
            else
              Net::HTTP::Get.new(uri)
            end

      req.basic_auth(@username, @password) if @username && @password
      req
    end
  end
end
