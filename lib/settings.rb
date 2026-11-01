require "ostruct"

module Settings
  class PqRestApi
    attr_reader :host, :username, :password

    def self.from_env
      host     = ENV["PQ_REST_API_HOST"] || (ENV["RAILS_ENV"] == "test" && "http://localhost:8888")
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

  # The three Azure credentials, in the order the boot-time guard reports them.
  # Tenant and client id are public identifiers and live in committed
  # configmaps; the secret comes from pq-secrets and is never committed.
  AZURE_CREDENTIAL_KEYS = %w[
    OMNIAUTH_AZURE_TENANT_ID
    OMNIAUTH_AZURE_CLIENT_ID
    OMNIAUTH_AZURE_CLIENT_SECRET
  ].freeze

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

  def parliamentary_team_email
    @h["parliamentary_team_email"]
  end

  def tech_support_email
    @h["tech_support_email"]
  end

  def govuk_notify_api_key
    ENV.fetch("GOVUK_NOTIFY_API_KEY", nil) || @h["govuk_notify_api_key"]
  end

  # The OAuth flags and credentials below read ENV on every call rather than
  # memoising at load time like @pq_rest_api above. Settings is required from
  # the bottom of config/application.rb, so an eager read would freeze a flag
  # before the environment is fully assembled and make it untestable.

  def oauth_azure_enabled?
    env_flag("OAUTH_AZURE_ENABLED")
  end

  # Defaults to false: every environment, including test and localhost, uses
  # the OAuth journey unless explicitly told otherwise. Set
  # PASSWORD_LOGIN_ENABLED=true to mount the password routes again — it needs a
  # restart, because routes are drawn at boot.
  def password_login_enabled?
    env_flag("PASSWORD_LOGIN_ENABLED", default: false)
  end

  def omniauth_azure_tenant_id
    ENV.fetch("OMNIAUTH_AZURE_TENANT_ID", nil)
  end

  def omniauth_azure_client_id
    ENV.fetch("OMNIAUTH_AZURE_CLIENT_ID", nil)
  end

  def omniauth_azure_client_secret
    ENV.fetch("OMNIAUTH_AZURE_CLIENT_SECRET", nil)
  end

  def azure_issuer
    "https://login.microsoftonline.com/#{omniauth_azure_tenant_id}/v2.0"
  end

  # The absolute host OmniAuth should build callback URLs from.
  #
  # Left unset, OmniAuth derives the callback URL from the request's Host or
  # X-Forwarded-Host header and warns on every request that this can be forged
  # unless something in front of the app checks it. Pinning it also guarantees
  # the redirect_uri Entra receives is https, which force_ssl plus the
  # ingress's X-Forwarded-Proto is expected to produce but does not guarantee.
  #
  # nil on localhost and in test, where there is no SENDING_HOST and deriving
  # from the request is what allows an arbitrary port to work.
  def omniauth_full_host
    host = ENV.fetch("SENDING_HOST", nil).to_s.strip
    return if host.empty?

    host.start_with?("http://", "https://") ? host : "https://#{host}"
  end

  # Failing at boot beats failing at a user's first sign-in. Only the variable
  # name is reported, never its value.
  def validate_azure_credentials!
    return unless ENV["RAILS_ENV"] == "production" && oauth_azure_enabled?

    AZURE_CREDENTIAL_KEYS.each do |key|
      next unless ENV.fetch(key, nil).to_s.strip.empty?

      raise "Cannot find environment variable #{key}. Please set it first"
    end
  end

  # An unset or empty flag takes the default; anything else must say "true"
  # exactly, so a typo fails closed rather than reading as enabled.
  def env_flag(name, default: true)
    value = ENV.fetch(name, nil)
    return default if value.nil? || value.strip.empty?

    value == "true"
  end

  private_class_method :env_flag

  validate_azure_credentials!
end
