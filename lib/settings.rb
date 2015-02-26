module Settings
  DEFAULT_GA_TRACKER_ID = 'UA-37377084-14'

  class PqRestApi
    attr_reader :host, :username, :password

    def self.from_env
      host     = ENV['PQ_REST_API_HOST']
      username = ENV['PQ_REST_API_USERNAME']
      password = ENV['PQ_REST_API_PASSWORD']

      raise "Cannot find environment variable PQ_REST_API_HOST. Please set it first" unless host

      if ENV['RAILS_ENV'] == 'production'
        raise "Cannot find environment variable PQ_REST_API_USERNAME. Please set it first" unless username
        raise "Cannot find environment variable PQ_REST_API_PASSWORD. Please set it first" unless password
      end

      new(host, username, password)
    end

    def initialize(host, username, password)
      @host     = host
      @username = username
      @password = password
    end
  end

  module_function
  filepath         = File.expand_path('../config/settings.yml', __dir__)
  @h               = YAML::load_file(filepath)
  @pq_rest_api     = PqRestApi.from_env

  def pq_rest_api
    @pq_rest_api
  end

  def mail_from
    @h['mail_from']
  end

  def mail_reply_to
    @h['mail_reply_to']
  end

  def mail_tech_support
    @h['mail_tech_support']
  end

  def http_client_timeout
    @h['http_client_timeout']
  end

  def ga_tracker_id
    ENV.fetch('GA_TRACKER_ID', DEFAULT_GA_TRACKER_ID)
  end
end
