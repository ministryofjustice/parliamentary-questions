module PQA
  class ApiClient
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

    def questions(date_from, date_to, status)
      uri       = File.join(@base_url, 'api/qais/questions')
      params    = {
        'dateFrom' => date_from.xmlschema,
        'dateTo'   => date_to && date_to.xmlschema,
        'status'   => status
      }
      uri.query = URI.encode_www_form(params)
      issue_request(:get, uri)
    end

    def save_question(uin, xml)
      uri = File.join(@base_url, 'api/qais/questions', uin)
      issue_request(:put, uri, xml)
    end

    def save_answer(uin, xml)
      uri = File.join(@base_url, 'api/qais/answers', uin)
      issue_request(:put, uri, xml)
    end

    def reset_mock_data!
      uri = File.join(@base_url, 'reset')
      issue_request(:put, uri)
    end

    protected

    def issue_request(method, uri_s, body = nil)
      uri = URI.parse(uri_s)
      req = case method
            when :put
              r = Net::HTTP::Put.new(uri)
              r.body = body
              r
            else
              Net::HTTP::Get.new(uri)
            end

      req.basic_auth(@username, @password) if @username && @password

      res = Net::HTTP.start(uri.hostname, uri.port) { |http|
        http.read_timeout = Settings.http_client_timeout
        http.request(req)
      }

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
  end
end
