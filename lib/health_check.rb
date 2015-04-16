module HealthCheck
  #
  # Module to check all system components are running & accessible
  #
  class Component
    #
    # Define interface to check if component passes the healthcheck
    #
    def available?
      #
      # Checks if component is running
      # Null -> Boolean
      #
      raise NotImplementedError, 'The #available? method should be implemented by subclasses'
    end

    def accessible?
      #
      # Checks if application can access component with supplied credentials
      # Null -> Boolean
      #
      raise NotImplementedError, 'The #accessible? method should be implemented by subclasses'
    end

    def error_messages
      #
      # Logs non-success response message from the component
      # Null -> Array[String]
      #
      raise NotImplementedError, 'The error_messages method should be implemented by subclasses'
    end

    protected
    
    def perform_get(uri_s)
      uri = URI.parse(uri_s)

      Net::HTTP.start(uri.host, uri.port) do |http|
        req = Net::HTTP::Get.new(uri)
        http.request(req) 
      end
    end

    def perform_post(uri_s, data_h)
      
    end
  end
end