module Export
  # NOTE :
  # The format of this CSV export is intended to match the structure of the
  # spredsheet used by Parli-branch for offline reporting.
  #
  # Column ordering must not be altered.
  #
  # For a sample, see https://dsdmoj.atlassian.net/wiki/display/PQ/Parli-branch+sample+spreadsheet

  class Base
    DATE_FORMAT  = '%Y-%m-%d %H:%M'

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
        pq.member_name,                                                 # 'MP',
        nil,                                                            # 'Record Number',
        ao && ao.name                                                   # 'Action Officer',
      ] +
      [
        pq.answer_submitted,                                            # 'Date response answered by Parly (dept)',
        pq.internal_deadline,                                           # 'Draft due to Parly Branch',
        pq.tabled_date,                                                 # 'Date First Appeared in Parliament',
        pq.date_for_answer,                                             # 'Date Due in Parliament',
        pq.resubmitted_to_answering_minister,                           # 'Date resubmitted to Minister (if appliable)',
        pq.answering_minister_returned_by_action_officer,               # 'Date returned by AO (if applicable)',
        pq.draft_answer_received,                                       # 'Date Draft Returned to PB',
        pq.answering_minister_to_action_officer,                        # 'Date sent back to AO (if applicable)',
        pq.sent_to_answering_minister,                                  # 'Date delivered to Minister',
        pq.cleared_by_answering_minister                                # 'Returned signed from Minister',
      ].map { |date| date && date.strftime(DATE_FORMAT) }  +
      [
        pq.directorate && pq.directorate.name,                          # 'Directorate',
        pq.original_division && pq.original_division.name,                                # 'Division',
        pq.answer,                                                      # 'Final Response',
        pq.question,                                                    # 'Full_PQ_subject',
        nil,                                                            # 'Delay Reason',
        pq.minister && pq.minister.name,                                # 'Minister',
        pq.answering_minister_query,                                    # 'Ministerial Query? (if applicable)',
        pq.uin,                                                         # 'PIN',
        pq.pod_clearance && pq.pod_clearance.strftime(DATE_FORMAT),     # '"Date/time of POD clearance"',
        pq.pod_query_flag,                                              # 'PODquery',
        pq.finance_interest,                                            # 'Requested by finance',
        nil,                                                            # 'Requested by HR',
        nil,                                                            # 'Requested by Press',
        pq.question_type,                                               # 'Type of Question',
        ao && ao.email                                                  # 'AO Email'
      ]
    end

    def rebase(date)
      date + 1.day - 1.minutes
    end
  end
end
