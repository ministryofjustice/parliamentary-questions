module PQA
  class Import
    def initialize(pqa_service = nil)
      @pqa_service         = pqa_service || PQAService.from_settings
      @logger              = LogStuff
      init_state!
    end

    def run(date_from, date_to)
      query_api_and_update(type: :date_range, date_from: date_from, date_to: date_to)
    end

    def run_for_question(uin)
      query_api_and_update(type: :uin, uin: uin)
    end


    private

    def query_api_and_update(options)
      init_state!
      ActiveRecord::Base.transaction do
        questions = []
        if options[:type] == :date_range
          questions = @pqa_service.questions(options[:date_from], options[:date_to])
        else
          questions = @pqa_service.question(options[:uin])
        end
        @total    = questions.size
        questions.each { |q| insert_or_update(q)  }
      end
      report
    end

    def init_state!
      @total   = 0
      @created = 0
      @updated = 0
      @errors  = {}
    end

    def report
      {
        total: @total,
        created: @created,
        updated: @updated,
        errors: @errors
      }
    end

    def insert_or_update(q)
      uin = q.uin
      pq  = Pq.find_or_initialize_by(uin: uin)

      pq.uin                 = uin
      pq.raising_member_id   = q.member_id
      pq.question            = q.text
      pq.tabled_date         = q.tabled_date
      pq.member_name         = q.member_name
      pq.member_constituency = q.member_constituency
      pq.house_name          = q.house_name
      pq.registered_interest = q.registered_interest
      pq.question_type       = q.question_type
      pq.question_status     = q.question_status
      pq.preview_url         = q.url
      pq.date_for_answer     = pq.date_for_answer || q.date_for_answer
      pq.transferred         ||= false
      pq.state               ||= PQState::UNASSIGNED

      if !pq.valid?
        error_msgs   = pq.errors.messages
        @errors[uin] = error_msgs
        @logger.warn { "Failed to import question with uin #{uin} (errors: #{error_msgs})" }
      elsif pq.new_record?
        @created += 1
        @logger.debug { "Imported new record (uin: #{uin})" }
        pq.save
      else
        @updated += 1
        @logger.debug { "Updating record (uin: #{uin})" }
        pq.save
      end



      LogStuff.tag(:import) do
        @logger.info { "Completed import: questions downloaded #{@total}, new #{@created}, updated #{@updated}, invalid: #{@errors.size}" }
      end
    end
  end
end
