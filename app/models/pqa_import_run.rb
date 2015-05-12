# == Schema Information
#
# Table name: pqa_import_runs
#
#  id             :integer          not null, primary key
#  start_time     :datetime
#  end_time       :datetime
#  status         :string(255)
#  num_created    :integer
#  num_updated    :integer
#  error_messages :text
#  created_at     :datetime
#  updated_at     :datetime
#

class PqaImportRun < ActiveRecord::Base

  scope :successful, -> { where("status != 'Failure'") }

  validates :status, inclusion: { in: %w(OK Failure OK_with_errors),  message: "Status must be 'OK', 'Failure' or 'OK_with_errors': was '%{value}'" }

  serialize :error_messages

  def self.last_import_time_utc
    rec = self.successful.order(:start_time).last
    if rec.nil?
      3.days.ago
    else
      rec.start_time.utc
    end
  end


  def self.record_success(start_time, import_run_report)
    self.create!(
      start_time:     start_time,
      end_time:       Time.now,
      num_created:    import_run_report[:created],
      num_updated:    import_run_report[:updated],
      status:         import_run_report[:errors].any? ? 'OK_with_errors' : 'OK',
      error_messages: import_run_report[:errors].any? ? import_run_report[:errors] : nil)
  end

  def self.record_failure(start_time, error_message)
    self.create!(
      start_time:     start_time,
      end_time:       Time.now,
      num_created:    0,
      num_updated:    0,
      status:         'Failure',
      error_messages: error_message)
  end

end
