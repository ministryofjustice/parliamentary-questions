require 'fileutils'

class PQA::Import
  def initialize(pid_filepath, pqa_service)
    @pid_filepath = pid_filepath
    @pqa_service  = pqa_service
  end

  def run(date_from, date_to)
    with_pid_file do
      @pqa_service.questions(date_from, date_to).each do |q|
        pq = upsert_question(q)
      end
    end
  end

  private

  def with_pid_file(&block)
    unless File.exists?(@pid_filepath)
      begin
        yield
      rescue StandardError => e
        FileUtils.rm @pid_filepath
        raise e
      end
    else
      pid = File.read(@pid_filepath)
      msg = "Looks like an PQ&A import is already running." +
            "Please manually kill the process (pid #{pid}) and remove #{@pid_filepath}"
      raise PIDFileFound, msg
    end
  end

  def upsert_question(q)
    uin = q.uin
    pq  = Pq.find_or_initialize_by(uin: q['Uin'])
    pq.update(
      uin: uin,
      raising_member_id: q.member_id,
      question: q.text,
      tabled_date: q.tabled_date,
      member_name: q.member_name,
      member_constituency: q.member_constituency,
      house_name: q.house_name,
      registered_interest: q.registered_interest,
      question_type: q.question_type,
      preview_url: q.url,
      question_status: q.status,
      date_for_answer: pq.date_for_answer || q.date_for_answer,
      transferred: q.transferred,
    )
    pq
  end

  class PIDFileFound < StdandardError
  end
end
