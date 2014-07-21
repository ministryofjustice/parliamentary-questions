class ImportService

	def initialize(questionsService = QuestionsService.new)
    	@questionsService = questionsService
      @progress_unallocated = Progress.unallocated
  end

	def questions_with_callback(args = { dateFrom: Date.today} , &block)
    t_start = Time.now

    questions = @questionsService.questions(args)

    questions.each do |q|
      import_one_question(q, &block)
    end

    move_questions_from_accepted_to_draft_pending

    # log the time in statsd
    elapsed_seconds = Time.now - t_start
    $statsd.timing("#{StatsHelper::IMPORT}.import_time", elapsed_seconds)
  end

  def questions_by_uin_with_callback(uin, &block)
    q = @questionsService.questions_by_uin(uin)
    import_one_question(q, &block)
  end


  def questions(args = { dateFrom: Date.today} )
    questions_processed = Array.new
    errors = Array.new



    questions_with_callback(args) { |result|
        if !result[:error].nil?
          errors.push({ message: result[:error], question: result[:question] })
        else
          questions_processed.push(result[:question])
        end
    }

    {questions: questions_processed, errors: errors}
  end

  def questions_by_uin(uin)
    questions_processed = Array.new
    errors = Array.new

    questions_by_uin_with_callback(uin) { |result|
      if !result[:error].nil?
        errors.push({ message: result[:error], question: result[:question] })
      else
        questions_processed.push(result[:question])
      end
    }
    {questions: questions_processed, errors: errors}
  end


  protected

  def import_one_question(q, &block)
    pq = PQ.find_or_initialize_by(uin: q['Uin'])
    default_deadline = DateTime.now.midnight.change ({:hour => 10, :min => 30, :offset => 0})
    deadline = pq.internal_deadline || default_deadline
    progress_id = pq.progress_id || @progress_unallocated.id
    transferred = pq.transferred || false
    pq.update(
        uin: q['Uin'],
        raising_member_id: q['TablingMember']['MemberId'],
        question: q['Text'],
        tabled_date: q['TabledDate'],
        member_name: q['TablingMember']['MemberName'],
        member_constituency: q['TablingMember']['Constituency'],
        house_name: q['House']['HouseName'],
        date_for_answer: q['DateForAnswer'],
        internal_deadline: deadline,
        registered_interest: q['RegisteredInterest'],
        question_type: q['QuestionType'],
        preview_url: q['Url'],
        question_status: q['QuestionStatus'],
        transferred: transferred,
        progress_id: progress_id
    )

    if pq.errors.empty?
      $statsd.increment("#{StatsHelper::IMPORT}.number_questions_imported.error")
      yield ({question: q})
    else
      $statsd.increment("#{StatsHelper::IMPORT}.number_questions_imported.success")
      yield ({question: q, error: pq.errors.full_messages})
    end

  end

  def move_questions_from_accepted_to_draft_pending
    beginning_of_day = DateTime.now.at_beginning_of_day.change({offset: 0})
    progress_id = Progress.draft_pending.id

    number_of_questions_moved = 0
    pqs = PQ.allocated_accepted.joins(:action_officers_pq).where('action_officers_pqs.updated_at < ?', beginning_of_day)
    pqs.each do |pq_relation|
      pq = PQ.find(pq_relation.id)
      pq.update(progress_id: progress_id )
      number_of_questions_moved +=1
    end

    Rails.logger.info "Import process, moved #{number_of_questions_moved} questions from Allocated Accepted"
    number_of_questions_moved
  end

end	