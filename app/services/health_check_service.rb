class HealthCheckService
  COMPONENT_CLASSES = 
  [
    HealthCheck::Database,
    HealthCheck::MailWorker,
    HealthCheck::PqaApi,
    HealthCheck::SendGrid
  ]

  def initialize
    @components = 
      COMPONENT_CLASSES
        .select(&:time_to_run?)
        .map(&:new)
  end

  def report
    @components.each do |component|
      component.available?
      component.accessible?
    end

    errors = @components.map(&:error_messages).flatten

    errors.empty? ? HealthCheckReport.ok : HealthCheckReport.fail(errors)
  end

  private

  HealthCheckReport = 
    Struct.new(:status, :messages) do 
      def self.ok
        new('200', 'All Components OK')
      end

      def self.fail(errors)
        new('500', errors)
      end
    end   
end
