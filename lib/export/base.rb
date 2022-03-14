module Export
  # NOTE :
  # The format of this CSV export is intended to match the structure of the
  # spredsheet used by Parli-branch for offline reporting.
  #
  # Column ordering must not be altered.
  #
  # For a sample, see https://dsdmoj.atlassian.net/wiki/display/PQ/Parli-branch+sample+spreadsheet

  class Base
    DATE_FORMAT = '%Y-%m-%d %H:%M'

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
      'AO Email',
      'Group email'
    ]

    def initialize(date_from, date_to, pqs_comma_separated = nil)
      @date_from = rebase(date_from)
      @date_to   = rebase(date_to)
      @pqs_list  = pqs_comma_separated
    end

    def to_csv
      CSV.generate do |csv|
        csv << HEADINGS
        pqs.each do |pq|
          csv << csv_fields(pq, pq.action_officers.first)
        end
      end
    end

    def empty_or_date(this_date)
      if this_date.nil?
        ''
      else
        this_date.strftime('%Y-%m-%d %H:%M')
      end
    end

    def escape_equals_for_excel(item)
      item = '' if item.nil?
      if item.to_s.start_with?('=')
        item = "'" + item
      else
        item
      end
    end

    private

    def pqs
      raise NotImplementedError, 'Subclasses should implement pqs method'
    end

    def csv_fields(pq, ao)
      [
        # 'MP',
        escape_equals_for_excel(pq.member_name),
        # 'Record Number',
        nil,
        # 'Action Officer',
        escape_equals_for_excel(ao && ao.name)
      ] +
        [
          # 'Date response answered by Parly (dept)',
          pq.answer_submitted,
          # 'Draft due to Parly Branch',
          pq.internal_deadline,
          # 'Date First Appeared in Parliament',
          pq.tabled_date,
          # 'Date Due in Parliament',
          pq.date_for_answer,
          # 'Date resubmitted to Minister (if appliable)',
          pq.resubmitted_to_answering_minister,
          # 'Date returned by AO (if applicable)',
          pq.answering_minister_returned_by_action_officer,
          # 'Date Draft Returned to PB',
          pq.draft_answer_received,
          # 'Date sent back to AO (if applicable)',
          pq.answering_minister_to_action_officer,
          # 'Date delivered to Minister',
          pq.sent_to_answering_minister,
          # 'Returned signed from Minister',
          pq.cleared_by_answering_minister
        ].map { |date| date && date.strftime(DATE_FORMAT) } +
        [
          # 'Directorate',
          escape_equals_for_excel(pq.directorate && pq.directorate.name),
          # 'Division',
          escape_equals_for_excel(pq.original_division && pq.original_division.name),
          # 'Final Response',
          escape_equals_for_excel(pq.answer),
          # 'Full_PQ_subject',
          escape_equals_for_excel(pq.question),
          # 'Delay Reason',
          nil,
          # 'Minister',
          escape_equals_for_excel(pq.minister && pq.minister.name),
          # 'Ministerial Query? (if applicable)',
          escape_equals_for_excel(pq.answering_minister_query),
          # 'PIN',
          escape_equals_for_excel(pq.uin),
          # '"Date/time of POD clearance"',
          pq.pod_clearance && pq.pod_clearance.strftime(DATE_FORMAT),
          # 'PODquery',
          escape_equals_for_excel(pq.pod_query_flag),
          # 'Requested by finance',
          escape_equals_for_excel(pq.finance_interest),
          # 'Requested by HR',
          nil,
          # 'Requested by Press',
          nil,
          # 'Type of Question',
          escape_equals_for_excel(pq.question_type),
          # 'AO Email'
          escape_equals_for_excel(ao && ao.email),
          # 'Group Email'
          escape_equals_for_excel(ao && ao.group_email)
        ]
    end

    def rebase(date)
      date + 1.day - 1.minute
    end
  end
end
