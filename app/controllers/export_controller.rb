class ExportController < ApplicationController
  before_action :authenticate_user!, PQUserFilter


  def index
  end

  def index_for_pod
  end
  
  def csv
    pqs = get_pqs(DateTime.parse(params[:date_to]), DateTime.parse(params[:date_from]), 'created_at >= ? AND updated_at <= ?')
    send_data to_csv(pqs.order(:uin))
  end

  def csv_for_pod
    pqs = get_pqs(DateTime.parse(params[:date_to]), DateTime.parse(params[:date_from]), 'created_at >= ? AND updated_at <= ? AND draft_answer_received is not null AND pod_clearance is null and answer_submitted is null')
    send_data to_csv(pqs.order(:date_for_answer))
  end

  private

  def get_pqs(date_to, date_from, sql)
    Pq.where(sql, date_from, date_to)
  end

  def to_csv(pqs)
    CSV.generate do |csv|
      csv << [
          'MP',
          'Record Number',
          'Action Officer',
          'Date response answered by Parly (dept)',
          'Draft due to Parly Branch',
          'Date First Appeared in Parliament',
          'Date Due in Parliament',
          'Date resubmitted to Minister (if appliable)',
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
      pqs.each do |pq|
        ao = pq.action_officer_accepted
        csv << pq_data_to_hash(pq,ao)
      end
    end
  end

  def pq_data_to_hash(pq,ao)
    ao_name = ao.nil? ? '' : ao.name
    ao_email = ao.nil? ? '' : ao.email
    division = pq.at_acceptance_division_id.nil? ? '' : Division.find(pq.at_acceptance_division_id).name
    directorate = pq.at_acceptance_directorate_id.nil? ? '' : Directorate.find(pq.at_acceptance_directorate_id).name
    minister_name = pq.minister.nil? ? '' : pq.minister.name
    [
        pq.member_name,           # 'MP',
        '',                       # 'Record Number',
        ao_name,                  # 'Action Officer',
        format(pq.answer_submitted),         # 'Date response answered by Parly (dept)',
        format(pq.internal_deadline),        # 'Draft due to Parly Branch',
        format(pq.tabled_date),              # 'Date First Appeared in Parliament',
        format(pq.date_for_answer),          # 'Date Due in Parliament',
        format(pq.resubmitted_to_answering_minister),             # 'Date resubmitted to Minister (if appliable)',
        format(pq.answering_minister_returned_by_action_officer), # 'Date returned by AO (if applicable)',
        format(pq.draft_answer_received),                         # 'Date Draft Returned to PB',
        format(pq.answering_minister_to_action_officer),          # 'Date sent back to AO (if applicable)',
        format(pq.sent_to_answering_minister),                    # 'Date delivered to Minister',
        format(pq.cleared_by_answering_minister),                 # 'Returned signed from Minister',
        directorate,                 # 'Directorate',
        division,                    # 'Division',
        pq.answer,                   # 'Final Response',
        pq.question,                 # 'Full_PQ_subject',
        '',                          # 'Delay Reason',
        minister_name,               # 'Minister',
        pq.answering_minister_query, # 'Ministerial Query? (if applicable)',
        pq.uin,                      # 'PIN',
        format(pq.pod_clearance),    # '"Date/time of POD clearance"',
        pq.pod_query_flag,           # 'PODquery',
        pq.finance_interest,         # 'Requested by finance',
        '',                          # 'Requested by HR',
        '',                          # 'Requested by Press',
        pq.question_type,            # 'Type of Question',
        ao_email,                    # 'AO Email'
    ]
  end

  def format(datetime)
    datetime_format = '%d/%m/%Y %H:%M'
    if datetime.nil?
      return ''
    end
    datetime.strftime(datetime_format)
  end

end