module PQA
  module QuestionBuilder
    module_function

    #def updated(uin, updated, status = nil)
    #  q = default(uin, status)
    #  q.updated_date    = updated
    #  q.date_for_answer = updated + 1.day
    #  q.tabled_date     = updated
    #  q
    #end

    #def date_for_answer(uin, d, status = nil)
    #  q = default(uin, status)
    #  q.date_for_answer = d
    #  q
    #end

    def default(uin)
      q                           = Question.new
      q.uin                       = uin
      q.updated_date              = DateTime.now.midnight
      q.date_for_answer           = q.updated_date + 1.day
      q.tabled_date               = q.updated_date

      q.answering_body_id         = '14'
      q.answering_body_name       = "Department of Environment, Food and Rural Affairs"
      q.answering_body_short_name = q.answering_body_name
      q.house_id                  = '1'
      q.house_name                = 'House of Commons'
      q.member_id                 = '2479'
      q.member_name               = 'Diana Johnson'
      q.member_constituency       = 'Kingston upon Hull North'
      q.question_status           = 'Tabled'
      q.question_type             = 'NamedDay'

      q.registered_interest       = false

      q.session                   = '2012-13'
      q.target                    = 'Secretary of State for Environment, Food, and Rural Affairs'
      q.text                      = "Mock question #{uin}"
      q.url                       = "http://example.com/questions/#{uin}"

      q.version_number            = 2
      q.parliament_number         = 55
      q.session_number            = 3
      q
    end
  end
end
