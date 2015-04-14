

class PqFixer

  def initialize(pqid)
    @pq = Pq.find(pqid)
    @log_messages = []
  end

  def fix!
    begin
      log("fixing PQID: #{@pq.id} UIN: #{@pq.uin}")
      #   for pod_query, pod_clearance, 
      #   set pod_clearance to answer submitted date
      if %w{ pod_query pod_clearance}.include?(pq.state)
        fix_pod_clearance
      end
    rescue => err
      puts "ERROR: #{err.class}  #{err.message}"
    ensure
      print_messages
    end
    print_log_messages
  end

  private

  def log(message)
    @log_messages << message
  end


  def print_log_messages
    @log_messages.each { |m| puts m }
  end


  def fix_pod_clearance
    @pq.update_attributes(pod_clearance: @pq.answer_submitted)
    log("#{@pq.id} UIN: #{@pq.uin} pod_clearance set to #{@pq.pod_clearance}")
  end




end