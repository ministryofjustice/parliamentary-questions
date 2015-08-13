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


  def self.sum_pqs_imported(range)
    valid_ranges = {
        :day   => Date.today.beginning_of_day,
        :week  => 7.days.ago.beginning_of_day,
        :month => 30.days.ago.beginning_of_day
      }
    raise ArgumentError.new("invalid range for sum_pqs_imported") unless valid_ranges.keys.include?(range)
    recs = self.where('start_time >= ?', valid_ranges[range])
    recs.inject(0) { |n, rec| n + rec.num_updated + rec.num_created }
  end

  def self.ready_for_early_bird
    if last_import_time_utc < Date.today()
      return false
    else
      rec = self.successful.order(:start_time).last
      case rec.status
        when "Failed"
          false
        when "OK_with_errors"
          false
        when "OK"
          true
        else
          false
      end
    end
  end
end
