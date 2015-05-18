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

  def update(components)
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

  def update(components) 
    components.key_metric.alert ? error('Key metric below threshold') : ok
    self
  end
end

class DbStatus < GeckoStatus
  def initialize
    super('Database')
  end

  def update(components) 
    components.health.db_status ? ok : error('Database inaccessible')
    self
  end
end

class SendgridStatus < GeckoStatus
  def initialize
    super('Sendgrid')
  end

  def update(components) 
    components.health.sendgrid_status ? ok : error("Unable to contact sendgrid")
    self
  end
end

class PqaApiStatus < GeckoStatus
  def initialize
    super('PQA API')
  end

  def update(components)
    components.health.pqa_api_status ? ok : error(components.health.pqa_api_error_message)
    self
  end
end

class MailStatus < GeckoStatus
  def initialize
    super('Email')
  end

  def update(components)
    mail_info = components.mail_info

    if mail_info.email_error?
      error(
        "Mails Waiting: #{mail_info.num_waiting} :: " + 
        "Mails Abandoned: #{mail_info.num_abandoned}"
      )
    elsif mail_info.token_error?
      warn(
        "Unanswered Tokens: #{mail_info.num_unanswered_tokens} ::" +
        "#{100 - (mail_info.pctg_answered_tokens || 0)}% of total"
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

  def update(components)
    pqa_import_info = components.pqa_import_info

    if pqa_import_info.last_run_time < 1.day.ago
      warn('Last run more than 1 day ago')
    elsif pqa_import_info.last_run_status == 'OK'
      ok(pqa_import_info.report)
    else
      error(pqa_import_info.report)
    end

    self
  end
end

class SmokeTestStatus < GeckoStatus
  def initialize
    super('Smoke Tests')
  end

  def update(components)
    if components.smoke_test_info.run_time < 1.day.ago
      warn('Last test run more than 1 day ago')
    elsif components.smoke_test_info.run_success?
      ok
    else
      error("Smoke Test Run Failure")
    end

    self
  end
end
