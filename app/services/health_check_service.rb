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
    @components.all?(&:available?) 
    @components.all?(&:accessible?)

    errors = @components.map(&:error_messages).flatten

    if errors.empty?
      HealthCheckReport.new('200', 'All Components OK')
    else
      HealthCheckReport.new('500', errors)
    end
  end

  HealthCheckReport = Struct.new(:status, :messages)
end