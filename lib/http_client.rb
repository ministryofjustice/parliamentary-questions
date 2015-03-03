require 'net/https'

class HTTPClient
  attr_reader :base_url

  def initialize(base_url, username, password, pem_file_path)
    @base_url      = base_url
    @username      = username
    @password      = password
    @pem_file_path = pem_file_path
  end

  def issue_request(method, uri_s, body = nil)
    uri  = URI.parse(uri_s)
    req  = build_request(method, uri, body)
    http = handle_https(uri, Net::HTTP.new(uri.hostname, uri.port))
    res  = http.request(req)

    case res.code
    when /^2/
      res
    else
      raise FailureResponse.new(req, res)
    end
  end

  class FailureResponse < StandardError
    def initialize(request, response)
      super("PQ rest API responded with non success code: #{response.code}," +
            " response: #{response.body} (request: #{request.inspect})")
    end
  end

  private

  def handle_https(uri, http)
    if uri.scheme == 'https'
      http.use_ssl     = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      cert_dir = ENV['CA_CERT']

      if cert_dir && File.directory?(cert_dir)
        http.ca_path = cert_dir
      else
        http.ca_file = @pem_file_path
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
