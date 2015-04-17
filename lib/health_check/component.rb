module HealthCheck
  class Component
    #
    # Define interface to check if component passes the healthcheck
    #
    def initialize
      @errors = []
    end

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
      @errors
    end
  end
end