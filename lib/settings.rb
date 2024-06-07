module Settings
  class PqRestApi
    attr_reader :host, :username, :password

    def self.from_env
      host     = ENV["PQ_REST_API_HOST"]
      username = ENV["PQ_REST_API_USERNAME"]
      password = ENV["PQ_REST_API_PASSWORD"]

      if %w[production].include?(ENV["RAILS_ENV"]) && !host
        raise "Cannot find environment variable PQ_REST_API_HOST. Please set it first"
      end

      if ENV["RAILS_ENV"] == "production"
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

  filepath         = File.expand_path("../config/settings.yml", __dir__)
  @h               = YAML.load_file(filepath)
  @config_keys     = @h.keys.map(&:to_sym)
  @pq_rest_api     = PqRestApi.from_env

  def pq_rest_api
    @pq_rest_api
  end

  def live_url
    @h["live_url"]
  end

  def mail_from
    @h["mail_from"]
  end

  def commission_mail_from
    @h["commission_mail_from"]
  end

  def mail_reply_to
    @h["mail_reply_to"]
  end

  def mail_tech_support
    @h["mail_tech_support"]
  end

  def http_client_timeout
    @h["http_client_timeout"]
  end

  def healthcheck_pqa_api_interval
    @h["healthcheck_pqa_api_interval"]
  end

  def mail_worker
    OpenStruct.new(@h["mail_worker"])
  end

  def smoke_test_runner
    OpenStruct.new(@h["smoke_test_runner"])
  end

  def key_metric_threshold
    @h["key_metric_threshold"]
  end

  def parliamentary_team_email
    @h["parliamentary_team_email"]
  end

  def tech_support_email
    @h["tech_support_email"]
  end

  def govuk_notify_api_key
    ENV.fetch("GOVUK_NOTIFY_API_KEY", nil) || @h["govuk_notify_api_key"]
  end
end
