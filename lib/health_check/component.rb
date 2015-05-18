module HealthCheck
  class Component
    #
    # Define interface to check if component passes the healthcheck
    #
    def initialize
      @errors = []
    end

    def self.time_to_run?
      #
      # Allows enforcing a minimum time period for refreshing checks on a component
      # Null -> Boolean
      #
      true
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

    def log_unknown_error(e)
      #
      # Logs errors that are not component specific
      # StandardError -> Null
      #
      @errors << "Error: #{e.message}\nDetails:#{e.backtrace}"
    end

    def record_result
      # no-op.  Overrrideen in subclasses that need to implement this behaviour.
    end
  end
end