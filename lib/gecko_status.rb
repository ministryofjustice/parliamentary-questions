class GeckoStatus
  attr_accessor :label, :color, :message
  attr_reader   :name

  def initialize(name)
    @name    = name
    @label   = "n/a"
    @color   = "red"
    @message = "unitialized"
  end

  def warn(message)
    @label   = "WARNING"
    @color   = "yellow"
    @message = message
  end

  def error(message)
    @label   = "ERROR"
    @color   = "red"
    @message = message
  end

  def ok(message = "")
    @label   = "OK"
    @color   = "green"
    @message = message
  end

  # def update(metrics)
  def update(_metrics)
    #
    # Update the gecko status from a metrics dashboard component
    #
    # MetricsDashboard::Component -> GeckoStatus
    #
    raise NotImplementedError, "The #update method should be implemented by subclasses"
  end
end

class KeyMetricStatus < GeckoStatus
  def initialize
    super("Key Metric")
  end

  def update(metrics)
    metrics.key_metric.alert ? error("Key metric below threshold") : ok
    self
  end
end

class DbStatus < GeckoStatus
  def initialize
    super("Database")
  end

  def update(metrics)
    metrics.health.db_status ? ok : error("Database inaccessible")
    self
  end
end

class PqaApiStatus < GeckoStatus
  def initialize
    super("PQA API")
  end

  def update(metrics)
    metrics.health.pqa_api_status ? ok : error(metrics.health.pqa_api_error_message)
    self
  end
end

class PqaImportStatus < GeckoStatus
  def initialize
    super("PQ Import")
  end

  def update(metrics)
    if metrics.pqa_import.last_run_time < 1.day.ago
      warn("Last run more than 1 day ago")
    elsif metrics.pqa_import.last_run_status == "OK"
      ok(metrics.pqa_import.report)
    else
      error(metrics.pqa_import.report)
    end

    self
  end
end

class SmokeTestStatus < GeckoStatus
  def initialize
    super("Smoke Tests")
  end

  def update(metrics)
    if metrics.smoke_tests.run_time < 1.day.ago
      warn("Last test run more than 1 day ago")
    elsif metrics.smoke_tests.run_success?
      ok
    else
      error("Smoke Test Run Failure")
    end

    self
  end
end
