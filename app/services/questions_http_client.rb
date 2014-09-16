class QuestionsHttpClient

  def initialize(base_url = Settings.pq_rest_api.url, username = Settings.pq_rest_api.username, password = Settings.pq_rest_api.password)
    @base_url = base_url
    @username = username
    @password = password

    @client = HTTPClient.new
    @client.set_auth(@base_url, @username, @password)
    @client.connect_timeout = Settings.http_client_timeout
    @client.receive_timeout = Settings.http_client_timeout
  end

  def questions(options = {})
    endpoint = URI::join(@base_url, '/api/qais/questions')
    begin
      Rails.logger.info { "Import: requesting questions from #{endpoint} with options #{options.inspect}"}
      response = @client.get(endpoint, options)
      if response.status_code==200
        response.content
      else
        email_params={
            code: response.status_code,
            time: Time.now
        }
        PqMailer.import_fail_email(email_params).deliver
        rails_log_and_raise_error "Import API call returned #{response.status_code}", 'API response non-valid'
        return
      end
    rescue HTTPClient::ConnectTimeoutError
      rails_log_and_raise_error "Connecting to API timed out after #{Settings.http_client_timeout}", 'API connection timed-out'
    rescue HTTPClient::ReceiveTimeoutError
      rails_log_and_raise_error "Receiving from API timed out after #{Settings.http_client_timeout}", 'API response timed-out'
    rescue Errno::ECONNREFUSED
      rails_log_and_raise_error 'Server refused connection', 'Server refused connection'
    # rescue => generic_error
    #   rails_log_and_raise_error generic_error.message, "Error #{generic_error.inspect} occurred during import"
    end
  end

  def question(uin)
    endpoint = URI::join(@base_url, "/api/qais/questions/#{uin}")
    response = @client.get(endpoint)
    response.content
  end

  def answer(uin, body)
    endpoint = URI::join(@base_url, "/api/qais/answers/#{uin}")
    response = @client.put(endpoint, body)
    {content: response.content, status: response.status}
  end
  def set_connect_timeout(sec)
    @client.connect_timeout = sec
  end
  def set_receive_timeout(sec)
    @client.receive_timeout = sec
  end
  private
  def rails_log_and_raise_error(log_msg, error_msg)
    Rails.logger.info log_msg
    $statsd.increment "#{StatsHelper::IMPORT_ERROR}"
    raise error_msg
  end
end