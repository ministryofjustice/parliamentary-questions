module Export
  class PqSelection < Base
    DATE_FORMAT = "%Y-%m-%d %H:%M".freeze

    HEADINGS = [
      "PIN",
      "MP",
      "Draft due to Parly Branch",
      "Date Due in Parliament",
      "Full_PQ_subject",
      "Minister",
      "Status",
      "Action Officer",
      "Division",
      "Type of Question",
      "Date First Appeared in Parliament",
      "Date Draft Returned to PB",
      "Date delivered to Minister",
      "Returned signed from Minister",
      "Date response answered by Parly (dept)",
    ].freeze

    def csv_fields(parliamentary_question, action_officer)
      [
        # 'PIN',
        escape_equals_for_excel(parliamentary_question.uin),
        # 'MP',
        escape_equals_for_excel(parliamentary_question.member_name),
        # 'Draft due to Parly Branch',
        empty_or_date(parliamentary_question.internal_deadline),
        # 'Date Due in Parliament',
        empty_or_date(parliamentary_question.date_for_answer),
        # 'Full_PQ_subject',
        escape_equals_for_excel(parliamentary_question.question),
        # 'Minister',
        escape_equals_for_excel(parliamentary_question.minister && parliamentary_question.minister.name),
        escape_equals_for_excel(PQState.state_label(parliamentary_question.state)),
        # 'Action Officer',
        escape_equals_for_excel(action_officer && action_officer.name),
        # 'Division',
        escape_equals_for_excel(parliamentary_question.original_division && parliamentary_question.original_division.name),
        # 'Type of Question',
        escape_equals_for_excel(parliamentary_question.question_type),
        # 'Date First Appeared in Parliament',
        empty_or_date(parliamentary_question.tabled_date),
        # 'Date Draft Returned to PB',
        empty_or_date(parliamentary_question.draft_answer_received),
        # 'Date delivered to Minister',
        empty_or_date(parliamentary_question.sent_to_answering_minister),
        # 'Returned signed from Minister',
        empty_or_date(parliamentary_question.cleared_by_answering_minister),
        # 'Date response answered by Parly (dept)',
        empty_or_date(parliamentary_question.answer_submitted),
      ]
    end

    def to_csv
      CSV.generate do |csv|
        csv << HEADINGS
        pqs.each { |pq| csv << csv_fields(pq, pq.action_officer_accepted) }
      end
    end

  private

    def pqs
      pqs_array = []
      @pqs_list&.split(",")&.map do |p|
        if Pq.find_by(uin: p).nil?
          return pqs_array
        else
          x = Pq.find_by(uin: p)
          pqs_array.push(x)
        end
      end
      pqs_array
    end
  end
end
