module HealthCheck
  class Database < Component

    def accessible?
      ActiveRecord::Base.connected? || log_error && false
    end

    alias_method :available?, :accessible?

    private

    def log_error
      @errors = [ 
        "Database Error: could not connect to #{config.database} " + 
        "on #{config.host} using #{config.adapter}" 
      ]
    end

    def config
      OpenStruct.new(Rails.configuration.database_configuration[Rails.env])
    end 
  end
end