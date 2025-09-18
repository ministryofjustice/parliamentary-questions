module PQA
  class Import
    def initialize(pqa_service = PQA::ApiClient.from_settings)
      @pqa_service = PQAService.new(pqa_service)
      @logger = LogStuff
      init_state!
    end

    def run(date_from, date_to)
      query_api_and_update do
        @pqa_service.questions(Time.find_zone("UTC").parse(date_from.to_s), Time.find_zone("UTC").parse(date_to.to_s), "Tabled")
      end
    end

    def run_for_question(uin)
      query_api_and_update do
        @pqa_service.question(uin)
      end
    end

  private

    def query_api_and_update(&block)
      init_state!
      questions = block.call
      @total = questions.size
      questions.each { |q| insert_or_update(q) }
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
        errors: @errors,
      }
    end

    def insert_or_update(question)
      uin = question.uin
      pq  = Pq.find_or_initialize_by(uin:)

      pq.uin                 = uin
      pq.raising_member_id   = question.member_id
      pq.question            = question.text
      pq.tabled_date         = question.tabled_date
      pq.member_name         = question.member_name
      pq.member_constituency = question.member_constituency
      pq.house_name          = question.house_name
      pq.registered_interest = question.registered_interest
      pq.question_type       = question.question_type
      pq.question_status     = question.question_status
      pq.preview_url         = question.url
      pq.date_for_answer     = pq.date_for_answer || question.date_for_answer
      pq.transferred         ||= false
      pq.state               ||= PqState::UNASSIGNED

      if !pq.valid?
        error_msgs   = pq.errors.messages
        @errors[uin] = error_msgs
        @logger.warn { "Failed to import question with uin #{uin} (errors: #{error_msgs})" }
      elsif pq.new_record?
        @created += 1
        @logger.debug { "Imported new record (uin: #{uin})" }
        pq.save!
      else
        @updated += 1
        @logger.debug { "Updating record (uin: #{uin})" }
        pq.save!
      end

      LogStuff.tag(:import) do
        @logger.info { "Completed import: questions downloaded #{@total}, new #{@created}, updated #{@updated}, invalid: #{@errors.size}" }
      end
    end
  end
end
