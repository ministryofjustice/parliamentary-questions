class MetricsDashboard

  attr_reader :health,
              :app_info,
              :mail,
              :pqa_import


  Struct.new('Health', :db_status, :sendgrid_status, :pqa_api_status)
  Struct.new('AppInfo', :version, :build_date, :build_tag, :git_sha)
  Struct.new('MailInfo', :num_waiting, :num_abandoned, :unanswered_tokens)
  Struct.new('PqaImportInfo', :last_run_time, :last_run_status, :pqs)
  Struct.new('NumPqsImported', :today, :this_week, :last_week)


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
    line = File.open(HealthCheck::PqaApi::TIMESTAMP_FILE, 'r') do |fp|
      fp.gets.chomp
    end
    timestamp, status, error_messages_as_json = line
    status == 'OK'
  end





end




# JSON format: usable in geckoboard. See https://developer.geckoboard.com/#list
