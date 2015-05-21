require 'uri'
require 'mechanize'

module SmokeTest
  class Base
    include Rails.application.routes.url_helpers

    SSL_CERT_DIR  = ENV['CA_CERT']
    SSL_CERT_FILE = File.expand_path('resources/pq.dsd.io.pem', __dir__)

    attr_reader :app_uri, :agent
    
    def self.from_env
      unless ENV['TEST_USER_PASS'] && ENV['TEST_USER']
        raise 'TEST_USER & TEST_USER_PASS env variables must be set to run smoke tests' 
      end

      new(
        ENV['SENDING_HOST'],
        ENV['TEST_USER'],
        ENV['TEST_USER_PASS']
      )
    end

    def passed?
      login_to_app
      
      all_checks_succeed?
    rescue
      false
    end

    protected

    def all_checks_succeed?
      raise NotImplementedError, '#all_checks_succeed? method should be implemented by subclasses'
    end

    def login_to_app
      agent.get app_uri.to_s
    
      agent.page.forms.first.tap do |f|
        f['user[email]']    = @user
        f['user[password]'] = @pass
        f.submit
      end
    end

    def initialize(app_url, user, pass)
      @app_uri = build_uri(app_url)
      @user    = user
      @pass    = pass
      @agent   = mechanize_instance
    end

    private

    def build_uri(app_url)
      uri          = URI.parse(app_url)
      uri.scheme ||= 'https'
      uri
    end

    def mechanize_instance
      Mechanize.new do |m|
        if app_uri.scheme == 'https'
          m.agent.http.verify_mode = OpenSSL::SSL::VERIFY_PEER  
          m.agent.cert_store       = cert_store
        end
      end
    end

    def cert_store
      store = OpenSSL::X509::Store.new

      if SSL_CERT_DIR
        store.add_path(SSL_CERT_DIR)
      else
        store.add_file(SSL_CERT_FILE)
      end
    end
  end
end