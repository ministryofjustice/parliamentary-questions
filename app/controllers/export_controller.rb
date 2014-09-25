class ExportController < ApplicationController
  before_action :authenticate_user!, PQUserFilter


  def index
  end

  def index_for_pod
  end
  
  def csv
    pqs = get_pqs('transfer_out_ogd_id is null AND created_at >=? AND updated_at <=?')
    send_data to_csv(pqs.order(:uin))
  end

  def csv_for_pod
    pqs = get_pqs('created_at >=? AND updated_at <=? AND draft_answer_received is not null AND pod_clearance is null and answer_submitted is null')
    send_data to_csv(pqs.order(:date_for_answer))
  end

  private
  def get_pqs(sql)
    Pq.where(sql, DateTime.parse(params[:date_from])+1.day-1.minutes, DateTime.parse(params[:date_to])+1.day-1.minute)
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
    pq_dates = format_pq_dates(pq)
    [ pq.member_name,               # 'MP',
      '',                           # 'Record Number',
      get_ao_name(ao),              # 'Action Officer',
      pq_dates[:as],                # 'Date response answered by Parly (dept)',
      pq_dates[:id],                # 'Draft due to Parly Branch',
      pq_dates[:td],                # 'Date First Appeared in Parliament',
      pq_dates[:dfa],               # 'Date Due in Parliament',
      pq_dates[:rtam],              # 'Date resubmitted to Minister (if appliable)',
      pq_dates[:amrbao],            # 'Date returned by AO (if applicable)',
      pq_dates[:dar],               # 'Date Draft Returned to PB',
      pq_dates[:amtao],             # 'Date sent back to AO (if applicable)',
      pq_dates[:stam],              # 'Date delivered to Minister',
      pq_dates[:cbam],              # 'Returned signed from Minister',
      get_original_directorate(pq), # 'Directorate',
      get_original_division(pq),    # 'Division',
      pq.answer,                    # 'Final Response',
      pq.question,                  # 'Full_PQ_subject',
      '',                           # 'Delay Reason',
      get_minister(pq),             # 'Minister',
      pq.answering_minister_query,  # 'Ministerial Query? (if applicable)',
      pq.uin,                       # 'PIN',
      pq_dates[:pc],                # '"Date/time of POD clearance"',
      pq.pod_query_flag,            # 'PODquery',
      pq.finance_interest,          # 'Requested by finance',
      '',                           # 'Requested by HR',
      '',                           # 'Requested by Press',
      pq.question_type,             # 'Type of Question',
      get_ao_email(ao)              # 'AO Email'
    ]
  end
  def get_original_division(pq)
    pq.at_acceptance_division_id.nil? ? '' : Division.find(pq.at_acceptance_division_id).name
  end
  def get_original_directorate(pq)
    pq.at_acceptance_directorate_id.nil? ? '' : Directorate.find(pq.at_acceptance_directorate_id).name
  end
  def get_minister(pq)
    pq.minister.nil? ? '' : pq.minister.name
  end
  def get_ao_name(ao)
    ao.nil? ? '' : ao.name
  end
  def get_ao_email(ao)
    ao.nil? ? '' : ao.email
  end
  def format(datetime)
    datetime_format = '%d/%m/%Y %H:%M'
    if datetime.nil?
      return ''
    end
    datetime.strftime(datetime_format)
  end

  def format_pq_dates(pq)
    {
        as: format(pq.answer_submitted),         # 'Date response answered by Parly (dept)',
        id: format(pq.internal_deadline),        # 'Draft due to Parly Branch',
        td: format(pq.tabled_date),              # 'Date First Appeared in Parliament',
        dfa: format(pq.date_for_answer),          # 'Date Due in Parliament',
        rtam: format(pq.resubmitted_to_answering_minister),             # 'Date resubmitted to Minister (if appliable)',
        amrbao: format(pq.answering_minister_returned_by_action_officer), # 'Date returned by AO (if applicable)',
        dar: format(pq.draft_answer_received),                         # 'Date Draft Returned to PB',
        amtao: format(pq.answering_minister_to_action_officer),          # 'Date sent back to AO (if applicable)',
        stam: format(pq.sent_to_answering_minister),                    # 'Date delivered to Minister',
        cbam: format(pq.cleared_by_answering_minister),                 # 'Returned signed from Minister',
        pc: format(pq.pod_clearance),     # '"Date/time of POD clearance"',
    }
  end
end