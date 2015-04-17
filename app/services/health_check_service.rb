class HealthCheckService
  def self.default
    new([
      HealthCheck::Database.new,
      HealthCheck::SendGrid.new,
      HealthCheck::PqaApi.new
    ])
  end

  def initialize(components)
    @components = components
  end

  def report
    if @components.all?(&:available?) && @components.all?(&:accessible?)
      HealthCheckReport.new(
        '200', 
        'All Components OK'
      )
    else
      HealthCheckReport.new(
        '500',
        @components.map(&:error_messages).flatten
      )
    end
  end

  HealthCheckReport = Struct.new(:status, :messages)
end