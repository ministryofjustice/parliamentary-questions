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
      msg = "PQ rest API responded with non success code: #{res.code}, response: #{res.body} (request: #{req.inspect})"
      LogStuff.error(msg)
      raise msg
    end
  rescue Net::ReadTimeout => err
    LogStuff.error "PQ rest api request timed out (request: #{req.inspect}, current timeout: #{http.read_timeout})"
    raise err
  rescue Errno::ECONNREFUSED => err
    LogStuff.error "PQ rest API refused HTTP connection"
    raise err
  end

  private

  def handle_https(uri, http)
    if uri.scheme == 'https'
      http.use_ssl     = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      cert_dir = ENV['CA_CERT']

      if cert_dir && File.directory?(cert_dir)
        http.ca_path(cert_dir)
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
