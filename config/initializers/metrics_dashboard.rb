class MetricsDashboard

  attr_reader :health,
              :app_info,
              :mail,
              :pqa_import


  Struct.new('Health', :db_status, :sendgrid_status, :pqa_api_status)
  Struct.new('AppInfo', :version, :build_date, :build_tag, :git_sha)
  Struct.new('MailInfo', :num_waiting, :num_abandoned, :num_unanswered_tokens)
  Struct.new('PqaImportInfo', :last_run_time, :last_run_status, :pqs)
  Struct.new('NumPqsImported', :today, :this_week, :this_month)


  def initialize
    @health         = Struct::Health.new
    @app_info       = Struct::AppInfo.new
    @mail           = Struct::MailInfo.new
    @pqa_import     = Struct::PqaImportInfo.new
    @pqa_import.pqs = Struct::NumPqsImported.new
  end


  def gather_metrics
    gather_health_metrics
    gather_app_info_metrics
    gather_mail_info_metrics
    gather_pqa_import_metrics
  end


  private

  def gather_pqa_import_metrics
    last_run = PqaImportRun.last
    @pqa_import.last_run_time   =  Time.use_zone('London') { last_run.start_time.in_time_zone }
    @pqa_import.last_run_status = last_run.status
    @pqa_import.pqs.today       = PqaImportRun.sum_pqs_imported(:day)
    @pqa_import.pqs.this_week   = PqaImportRun.sum_pqs_imported(:week)
    @pqa_import.pqs.this_month  = PqaImportRun.sum_pqs_imported(:month)
  end


  def gather_mail_info_metrics
    @mail.num_waiting = Email.waiting.size
    @mail.num_abandoned = Email.abandoned.size
    @mail.num_unanswered_tokens = 666
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
    return false unless File.exist?(HealthCheck::PqaApi::TIMESTAMP_FILE)

    line = File.open(HealthCheck::PqaApi::TIMESTAMP_FILE, 'r') do |fp|
      fp.gets.chomp
    end
    timestamp, status, error_messages_as_json = line.split('::')
    last_run_time = Time.at(timestamp.to_i).utc
    if last_run_time + (Settings.healthcheck_pqa_api_interval + 5).minutes < Time.now.utc
      return false
    end
    status == 'OK'
  end

end




# JSON format: usable in geckoboard. See https://developer.geckoboard.com/#list
