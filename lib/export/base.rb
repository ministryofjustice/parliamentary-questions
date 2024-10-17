module Export
  # Note
  # The format of this CSV export is intended to match the structure of the
  # spredsheet used by Parli-branch for offline reporting.
  #
  # Column ordering must not be altered.
  #
  # For a sample, see https://dsdmoj.atlassian.net/wiki/display/PQ/Parli-branch+sample+spreadsheet

  class Base
    DATE_FORMAT = "%Y-%m-%d %H:%M".freeze

    HEADINGS = [
      "MP",
      "Record Number",
      "Action Officer",
      "Date response answered by Parly (dept)",
      "Draft due to Parly Branch",
      "Date First Appeared in Parliament",
      "Date Due in Parliament",
      "Date Draft Returned to PB",
      "Date delivered to Minister",
      "Returned signed from Minister",
      "Directorate",
      "Division",
      "Final Response",
      "Full_PQ_subject",
      "Delay Reason",
      "Minister",
      "PIN",
      '"Date/time of POD clearance"',
      "Requested by HR",
      "Requested by Press",
      "Type of Question",
      "AO Email",
      "Group email",
    ].freeze

    def initialize(date_from, date_to, pqs_comma_separated = nil)
      @date_from = rebase(date_from)
      @date_to   = rebase(date_to)
      @pqs_list  = pqs_comma_separated
    end

    def to_csv
      CSV.generate do |csv|
        csv << HEADINGS
        pqs.each do |pq|
          csv << csv_fields(pq, pq.action_officer_accepted)
        end
      end
    end

    def empty_or_date(this_date)
      if this_date.nil?
        ""
      else
        this_date.strftime("%Y-%m-%d %H:%M")
      end
    end

    def escape_equals_for_excel(item)
      item = "" if item.nil?
      if item.to_s.start_with?("=")
        "'#{item}"
      else
        item
      end
    end

  private

    def pqs
      raise NotImplementedError, "Subclasses should implement pqs method"
    end

    def csv_fields(parliamentary_question, action_officer)
      [
        # 'MP',
        escape_equals_for_excel(parliamentary_question.member_name),
        # 'Record Number',
        nil,
        # 'Action Officer',
        escape_equals_for_excel(action_officer && action_officer.name),
      ] +
        [
          # 'Date response answered by Parly (dept)',
          parliamentary_question.answer_submitted,
          # 'Draft due to Parly Branch',
          parliamentary_question.internal_deadline,
          # 'Date First Appeared in Parliament',
          parliamentary_question.tabled_date,
          # 'Date Due in Parliament',
          parliamentary_question.date_for_answer,
          # 'Date Draft Returned to PB',
          parliamentary_question.draft_answer_received,
          # 'Date delivered to Minister',
          parliamentary_question.sent_to_answering_minister,
          # 'Returned signed from Minister',
          parliamentary_question.cleared_by_answering_minister,
        ].map { |date| date && date.strftime(DATE_FORMAT) } +
        [
          # 'Directorate',
          escape_equals_for_excel(parliamentary_question.directorate && parliamentary_question.directorate.name),
          # 'Division',
          escape_equals_for_excel(parliamentary_question.original_division && parliamentary_question.original_division.name),
          # 'Final Response',
          escape_equals_for_excel(parliamentary_question.answer),
          # 'Full_PQ_subject',
          escape_equals_for_excel(parliamentary_question.question),
          # 'Delay Reason',
          nil,
          # 'Minister',
          escape_equals_for_excel(parliamentary_question.minister && parliamentary_question.minister.name),
          # 'PIN',
          escape_equals_for_excel(parliamentary_question.uin),
          # '"Date/time of POD clearance"',
          parliamentary_question.pod_clearance && parliamentary_question.pod_clearance.strftime(DATE_FORMAT),
          # 'Requested by HR',
          nil,
          # 'Requested by Press',
          nil,
          # 'Type of Question',
          escape_equals_for_excel(parliamentary_question.question_type),
          # 'AO Email'
          escape_equals_for_excel(action_officer && action_officer.email),
          # 'Group Email'
          escape_equals_for_excel(action_officer && action_officer.group_email),
        ]
    end

    def rebase(date)
      date + 1.day - 1.minute
    end
  end
end
