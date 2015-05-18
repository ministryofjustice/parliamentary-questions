class MetricsDashboard

  attr_reader :health,
              :app_info,
              :mail,
              :pqa_import,
              :gecko


  Struct.new('Health', :db_status, :sendgrid_status, :pqa_api_status)
  Struct.new('AppInfo', :version, :build_date, :build_tag, :git_sha)
  Struct.new('MailInfo', :num_waiting, :num_abandoned, :num_unanswered_tokens)
  Struct.new('PqaImportInfo', :last_run_time, :last_run_status, :pqs)
  Struct.new('NumPqsImported', :today, :this_week, :this_month)
  

  def initialize
    @health                = Struct::Health.new
    @app_info              = Struct::AppInfo.new
    @mail                  = Struct::MailInfo.new
    @pqa_import            = Struct::PqaImportInfo.new
    @pqa_import.pqs        = Struct::NumPqsImported.new
    @gecko                 = GeckoCollection.new
    @pqa_api_error_message = nil
  end


  def gather_metrics
    gather_health_metrics
    gather_app_info_metrics
    gather_mail_info_metrics
    gather_pqa_import_metrics
  end


  private
  

  def gather_pqa_import_metrics
    last_run = PqaImportRun.last || create_empty_import_run
    @pqa_import.last_run_time   =  Time.use_zone('London') { last_run.start_time.in_time_zone }
    @pqa_import.last_run_status = last_run.status
    @pqa_import.pqs.today       = PqaImportRun.sum_pqs_imported(:day)
    @pqa_import.pqs.this_week   = PqaImportRun.sum_pqs_imported(:week)
    @pqa_import.pqs.this_month  = PqaImportRun.sum_pqs_imported(:month)
    if last_run.start_time < 1.day.ago
      @gecko.pqa_import.warn('Last run more than 1 day ago')
    elsif last_run.status = 'OK'
      @gecko.pqa_import.ok("#{@pqa_import.pqs.today} :: #{@pqa_import.pqs.this_week} :: #{ @pqa_import.pqs.this_month}")
    else
      @gecko.pqa_import.error("#{@pqa_import.pqs.today} :: #{@pqa_import.pqs.this_week} :: #{ @pqa_import.pqs.this_month}")
    end
  end



  def gather_mail_info_metrics
    @mail.num_waiting = Email.waiting.size
    @mail.num_abandoned = Email.abandoned.size
    @mail.num_unanswered_tokens = 666
    if @mail.num_waiting >= Settings.gecko_warning_levels.num_emails_waiting || @mail.num_abandoned >= Settings.gecko_warning_levels.num_emails_abandoned
      @gecko.mail.error("Mails Waiting: #{@mail.num_waiting} :: Mails Abandoned: #{@mail.num_abandoned}")
    elsif @mail.num_unanswered_tokens > Settings.gecko_warning_levels.num_unanswered_tokens
      @gecko.mail.warn("Unanswered Tokens: #{@mail.num_unanswered_tokens}")
    else
      @gecko.mail.update_satus("OK", 'green')
    end
  end



  def gather_app_info_metrics
    info                 = Deployment.info
    @app_info.version    = info[:version_number]
    @app_info.build_date = info[:build_date]
    @app_info.build_tag  = info[:build_tag]
    @app_info.git_sha    = info[:commit_id]
  end
  
  def gather_health_metrics
    @health.db_status = get_db_status
    @health.sendgrid_status = get_sendgrid_status
    @health.pqa_api_status = get_pqa_api_status

    @health.db_status == true ? @gecko.db.ok : @gecko.db.error('Database inaccessible')
    @health.sendgrid_status == true ? @gecko.sendgrid.ok : @gecko.sendgrid.error("Unable to contact sendgrid")
    @health.pqa_api_status == true ? @gecko.pqa_api.ok : @gecko.pqa_api.error(@pqa_api_error_message)
  end


  def get_db_status
    checker = HealthCheck::Database.new
    checker.accessible? && checker.available?
  end


  def get_sendgrid_status
    checker = HealthCheck::SendGrid.new
    checker.accessible? && checker.available?
  end

  def get_pqa_api_status

    unless File.exist?(HealthCheck::PqaApi::TIMESTAMP_FILE)
      @pqa_api_error_message = "Unable to open #{HealthCheck::PqaApi::TIMESTAMP_FILE}"
      return false
    end

    line = File.open(HealthCheck::PqaApi::TIMESTAMP_FILE, 'r') do |fp|
      fp.gets.chomp
    end
    timestamp, status, error_messages_as_json = line.split('::')
    last_run_time = Time.at(timestamp.to_i).utc
    if last_run_time + (Settings.healthcheck_pqa_api_interval + 5).minutes < Time.now.utc
      @pqa_api_error_message = "PQA API not checked since #{last_run_time}"
      return false
    end

    if status != 'OK'
      @pqa_api_error_message = "Last API check had status #{status}"
      return false
    end
    @pqa_api_error_message = ""
    true
  end

  def create_empty_import_run
    PqaImportRun.new(
      :start_time     => Time.at(0),
      :end_time       => Time.at(0),
      :status         => 'FAIL',
      :num_created    => 0,
      :num_updated    => 0,
      :error_messages => []
    )
  end

end

