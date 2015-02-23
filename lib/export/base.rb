module Export
  class Base
    EXPORT_DATE_FORMAT  = '%Y-%m-%d'

    HEADINGS = [
      'MP',
      'Record Number',
      'Action Officer',
      'Date response answered by Parly (dept)',
      'Draft due to Parly Branch',
      'Date First Appeared in Parliament',
      'Date Due in Parliament',
      'Date resubmitted to Minister (if applicable)',
      'Date returned by AO (if applicable)',
      'Date Draft Returned to PB',
      'Date sent back to AO (if applicable)',
      'Date delivered to Minister',
      'Returned signed from Minister',
      'Directorate',
      'Division',
      'Final Response',
      'Full_PQ_subject',
      'Delay Reason',
      'Minister',
      'Ministerial Query? (if applicable)',
      'PIN',
      '"Date/time of POD clearance"',
      'PODquery',
      'Requested by finance',
      'Requested by HR',
      'Requested by Press',
      'Type of Question',
      'AO Email'
    ]

    def initialize(date_from, date_to)
      @date_from = rebase(date_from)
      @date_to   = rebase(date_to)
    end

    def to_csv
      CSV.generate do |csv|
        csv << HEADINGS
        pqs.each { |pq| csv << csv_fields(pq, pq.action_officer_accepted) }
      end
    end

    private

    def pqs
      raise NotImplementedError, "Subclasses should implement pqs method"
    end

    def csv_fields(pq, ao)
      [
        pq.member_name,
        nil,
        ao && ao.name
      ] +
      [
        pq.answer_submitted,
        pq.internal_deadline,
        pq.tabled_date,
        pq.date_for_answer,
        pq.resubmitted_to_answering_minister,
        pq.answering_minister_returned_by_action_officer,
        pq.draft_answer_received,
        pq.answering_minister_to_action_officer,
        pq.sent_to_answering_minister,
        pq.cleared_by_answering_minister
      ].map { |date| date && date.to_s(EXPORT_DATE_FORMAT) }  +
      [
        pq.directorate && pq.directorate.name,
        pq.division && pq.division.name,
        pq.answer,
        pq.question,
        nil,
        pq.minister && pq.minister.name,
        pq.answering_minister_query,
        pq.uin,
        pq.pod_clearance && pq.pod_clearance.to_s(EXPORT_DATE_FORMAT),
        pq.pod_query_flag,
        pq.finance_interest,
        nil,
        nil,
        pq.question_type,
        ao && ao.email
      ]
    end
    def rebase(date)
      date + 1.day - 1.minutes
    end
  end
end
