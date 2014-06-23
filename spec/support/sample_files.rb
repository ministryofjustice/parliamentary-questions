def sample_questions
  File.open('spec/fixtures/questions.xml')
end

def import_questions_for_today
  File.open('spec/fixtures/import_questions_for_today.xml')
end


def import_questions_for_today_with_changes
  File.open('spec/fixtures/import_questions_for_today_with_changes.xml')
end

def import_questions_for_today_with_missing_uin
  File.open('spec/fixtures/import_questions_for_today_with_missing_uin.xml')
end

def sample_questions_by_uin
  File.open('spec/fixtures/questions_by_uin.xml')
end

def sample_answer
  File.open('spec/fixtures/sample_answer.xml')
end

def sample_answer_error
  File.open('spec/fixtures/sample_answer_error.xml')
end

def sample_question_for_answer
  File.open('spec/fixtures/sample_question_for_answer.xml')
end