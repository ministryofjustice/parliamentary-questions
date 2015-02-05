module Settings
  module_function
  filepath = File.expand_path('../config/settings.yml', __dir__)
  @h = YAML::load_file(filepath)

  def pq_rest_api
    PqRestApi.from_env
  end

  def mail_from
    @h['mail_from']
  end

  def mail_reply_to
    @h['mail_reply_to']
  end

  def members_api_url
    @h['members_api_url']
  end

  def mail_tech_support
    @h['mail_tech_support']
  end

  def http_client_timeout
    @h['http_client_timeout']
  end

  class PqRestApi
    attr_reader :url, :username, :password

    def self.from_env
      url      = ENV['PQ_REST_API_URL']
      username = ENV['PQ_REST_API_USERNAME']
      password = ENV['PQ_REST_API_PASSWORD']

      raise "Cannot find environment variable PQ_REST_API_URL. Please set it first" unless url

      if ENV['RAILS_ENV'] == 'production'
        raise "Cannot find environment variable PQ_REST_API_USERNAME. Please set it first" unless username
        raise "Cannot find environment variable PQ_REST_API_PASSWORD. Please set it first" unless password
      end

      new(url, username, password)
    end

    def initialize(url, username, password)
      @url      = url
      @username = username
      @password = password
    end
  end
end
