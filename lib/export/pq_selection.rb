module Export
  class PqSelection < Base
    DATE_FORMAT = '%Y-%m-%d %H:%M'

    HEADINGS = [
      'PIN',
      'MP',
      'Draft due to Parly Branch',
      'Date Due in Parliament',
      'Full_PQ_subject',
      'Minister',
      'Status',
      'Action Officer',
      'Division',
      'Type of Question',
      'Date First Appeared in Parliament',
      'Date Draft Returned to PB',
      'Date delivered to Minister',
      'Returned signed from Minister',
      'Date response answered by Parly (dept)'
    ]

    def csv_fields(pq, ao)
      [
        # 'PIN',
        escape_equals_for_excel(pq.uin),
        # 'MP',
        escape_equals_for_excel(pq.member_name),
        # 'Draft due to Parly Branch',
        empty_or_date(pq.internal_deadline),
        # 'Date Due in Parliament',
        empty_or_date(pq.date_for_answer),
        # 'Full_PQ_subject',
        escape_equals_for_excel(pq.question),
        # 'Minister',
        escape_equals_for_excel(pq.minister && pq.minister.name),
        escape_equals_for_excel(PQState.state_label(pq.state)),
        # 'Action Officer',
        escape_equals_for_excel(ao && ao.name),
        # 'Division',
        escape_equals_for_excel(pq.original_division && pq.original_division.name),
        # 'Type of Question',
        escape_equals_for_excel(pq.question_type),
        # 'Date First Appeared in Parliament',
        empty_or_date(pq.tabled_date),
        # 'Date Draft Returned to PB',
        empty_or_date(pq.draft_answer_received),
        # 'Date delivered to Minister',
        empty_or_date(pq.sent_to_answering_minister),
        # 'Returned signed from Minister',
        empty_or_date(pq.cleared_by_answering_minister),
        # 'Date response answered by Parly (dept)',
        empty_or_date(pq.answer_submitted)
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
      @pqs_list&.split(',')&.map do |p|
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
