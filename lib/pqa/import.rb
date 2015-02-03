module PQA
  class Import
    def initialize(pqa_service = nil)
      @pqa_service  = pqa_service || PQAService.from_settings
      @logger       = LogStuff

      # import reporting
      @total        = 0
      @created      = 0
      @updated      = 0
      @errors       = {}
    end

    def run(date_from, date_to)
      ActiveRecord::Base.transaction do
        questions = @pqa_service.questions(date_from, date_to)
        @total    = questions.size

        questions.each do |q|
          upsert_question(q)
        end
        update_date_for_answers
      end
      report
    end

    private

    def report
      {
        total: @total,
        created: @created,
        updated: @updated,
        errors: @errors
      }
    end

    def update_date_for_answers
      Pq.find_each(25) do |pq|
        unless pq.date_for_answer
          pq.date_for_answer_has_passed = true
          pq.days_from_date_for_answer = LARGEST_POSTGRES_INTEGER
        else
          pq.date_for_answer_has_passed = pq.date_for_answer < Date.today
          pq.days_from_date_for_answer = (pq.date_for_answer - Date.today).abs
        end
        pq.save
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

      if pq.errors?
        error_msgs   = pq.errors.messages
        @errors[uin] = error_msgs
        @logger.warn "Failed to import question with uin #{uin} (errors: #{error_msgs})"
      elsif pq.new_record?
        @created += 1
        @logger.debug "Imported new record (uin: #{uin})"
      else
        @updated += 1
        @logger.debug "Updating record (uin: #{uin})"
      end

      @logger.info "Completed import: questions downloaded #{@total}, new #{@created}, updated #{@updated}, invalid: #{@errors.size}"
    end
  end
end
