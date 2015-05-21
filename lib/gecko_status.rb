class GeckoStatus
  attr_accessor :label, :color, :message
  attr_reader   :name

  def initialize(name)
    @name    = name
    @label   = "n/a"
    @color   = 'red'
    @message = 'unitialized'
  end

  def warn(message)
    @label   = 'WARNING'
    @color   = 'yellow'
    @message = message
  end

  def error(message)
    @label   = 'ERROR'
    @color   = 'red'
    @message = message
  end

  def ok(message = "")
    @label   = 'OK'
    @color   = 'green'
    @message = message
  end

  def update(metrics)
    #
    # Update the gecko status from a metrics dashboard component
    #
    # MetricsDashboard::Component -> GeckoStatus
    #
    raise NotImplementedError, 'The #update method should be implemented by subclasses'
  end
end

class KeyMetricStatus < GeckoStatus
  def initialize
    super('Key Metric')
  end

  def update(metrics) 
    metrics.key_metric.alert ? error('Key metric below threshold') : ok
    self
  end
end

class DbStatus < GeckoStatus
  def initialize
    super('Database')
  end

  def update(metrics) 
    metrics.health.db_status ? ok : error('Database inaccessible')
    self
  end
end

class SendgridStatus < GeckoStatus
  def initialize
    super('Sendgrid')
  end

  def update(metrics) 
    metrics.health.sendgrid_status ? ok : error("Unable to contact sendgrid")
    self
  end
end

class PqaApiStatus < GeckoStatus
  def initialize
    super('PQA API')
  end

  def update(metrics)
    metrics.health.pqa_api_status ? ok : error(metrics.health.pqa_api_error_message)
    self
  end
end

class MailStatus < GeckoStatus
  def initialize
    super('Email')
  end

  def update(metrics)
    if metrics.mail.email_error?
      error(
        "Mails Waiting: #{metrics.mail.num_waiting} :: " + 
        "Mails Abandoned: #{metrics.mail.num_abandoned}"
      )
    elsif metrics.mail.token_error?
      warn(
        "Unanswered Tokens: #{metrics.mail.num_unanswered_tokens} ::" +
        "#{100 - (metrics.mail.pctg_answered_tokens || 0)}% of total"
      )
    else
      ok
    end

    self
  end
end

class PqaImportStatus < GeckoStatus
  def initialize
    super('PQ Import') 
  end

  def update(metrics)
    if metrics.pqa_import.last_run_time < 1.day.ago
      warn('Last run more than 1 day ago')
    elsif metrics.pqa_import.last_run_status == 'OK'
      ok(metrics.pqa_import.report)
    else
      error(metrics.pqa_import.report)
    end

    self
  end
end

class SmokeTestStatus < GeckoStatus
  def initialize
    super('Smoke Tests')
  end

  def update(metrics)
    if metrics.smoke_tests.run_time < 1.day.ago
      warn('Last test run more than 1 day ago')
    elsif metrics.smoke_tests.run_success?
      ok
    else
      error("Smoke Test Run Failure")
    end

    self
  end
end
