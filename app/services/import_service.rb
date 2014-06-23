class ImportService

	def initialize(questionsService = QuestionsService.new)
    	@questionsService = questionsService
  	end

	def questions(args = { dateFrom: Date.today} )
    questions = @questionsService.questions(args)

    questions_processed = Array.new
		errors = Array.new
    pro = Progress.unallocated

    questions.each do |q|
	      	pq = import_one_question(pro, q)
			if pq.errors.empty?			
				questions_processed.push(q)			
			else				
				errors.push({ message: pq.errors.full_messages, question:q })
			end
    end
    {questions: questions_processed, errors: errors}
  end


  def questions_by_uin(uin)
    q = @questionsService.questions_by_uin(uin)

    questions_processed = Array.new
    errors = Array.new
    pro = Progress.unallocated

    pq = import_one_question(pro, q)
    if pq.errors.empty?
      questions_processed.push(q)
    else
      errors.push({ message: pq.errors.full_messages, question:q })
    end

    {questions: questions_processed, errors: errors}
  end


  protected

  def import_one_question(progress, q)
    pq = PQ.find_or_initialize_by(uin: q['Uin'])
    default_deadline = DateTime.now.midnight.change ({:hour => 10, :min => 30, :offset => 0})
    deadline = pq.internal_deadline || default_deadline
    progress_id = pq.progress_id || progress.id
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
        progress_id: progress_id
    )
    pq
  end
end	