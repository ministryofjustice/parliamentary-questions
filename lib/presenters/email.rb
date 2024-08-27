module Presenters
  module Email
  module_function

    def format_internal_deadline(parliamentary_question)
      parliamentary_question.internal_deadline ? "#{parliamentary_question.internal_deadline.to_formatted_s(:date)} - #{parliamentary_question.internal_deadline.strftime('%I').to_i}#{parliamentary_question.internal_deadline.strftime('%p').downcase} " : ""
    end

    def answer_by_text(parliamentary_question)
      "To be answered by: #{parliamentary_question.minister&.name}" if parliamentary_question.minister.present?
    end

    def member_name_text(parliamentary_question)
      "Asked by #{parliamentary_question.member_name}" if parliamentary_question.member_name.present?
    end

    def member_constituency_text(parliamentary_question)
      "Constituency #{parliamentary_question.member_constituency}" if parliamentary_question.member_constituency.present?
    end

    def internal_deadline_text(parliamentary_question)
      "The internal deadline is: #{format_internal_deadline(parliamentary_question)}" if parliamentary_question.internal_deadline.present?
    end

    def date_to_parliament_text(parliamentary_question)
      "Due back to Parliament #{parliamentary_question.date_for_answer.try(:to_formatted_s, :date)}" if parliamentary_question.date_for_answer.present?
    end
  end
end
