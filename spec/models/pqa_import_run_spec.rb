# == Schema Information
#
# Table name: pqa_import_runs
#
#  id             :integer          not null, primary key
#  start_time     :datetime
#  end_time       :datetime
#  status         :string
#  num_created    :integer
#  num_updated    :integer
#  error_messages :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require "rails_helper"

describe PQAImportRun, type: :model do
  context "when validating" do
    it "errors if status is not ok or failure or ok_with_errors" do
      pir = FactoryBot.build(:pqa_import_run, status: "gobbledygook")
      expect(pir).not_to be_valid
      expect(pir.errors[:status]).to eq ["Status must be 'OK', 'Failure' or 'OK_with_errors': was 'gobbledygook'"]
    end

    it "does not error if status ok" do
      pir = FactoryBot.build(:pqa_import_run)
      expect(pir).to be_valid
    end

    it "does not error is status failure" do
      pir = FactoryBot.build(:pqa_import_run, status: "Failure")
      expect(pir).to be_valid
    end

    it "does not error is status ok_with_errors" do
      pir = FactoryBot.build(:pqa_import_run, status: "OK_with_errors")
      expect(pir).to be_valid
    end
  end

  describe ".last_import_time_utc" do
    it "returns start of epoch if no records in the database" do
      Timecop.freeze(Time.zone.local(2015, 5, 7, 11, 15, 45)) do
        expect(described_class.count).to eq 0
        expect(described_class.last_import_time_utc).to eq(3.days.ago)
        expect(described_class.last_import_time_utc.zone).to eq "UTC"
      end
    end

    it "returns the start time of the last record" do
      times = [10.seconds.ago, 1.day.ago, 2.days.ago]
      latest_time = times.first

      times.each { |t| FactoryBot.create(:pqa_import_run, start_time: t, end_time: t + 3.seconds) }
      expect(times_equal?(described_class.last_import_time_utc, latest_time)).to be true
      expect(described_class.last_import_time_utc.zone).to eq "UTC"
    end

    it "ignores failure records" do
      Timecop.freeze do
        records = {
          10.seconds.ago => "Failure",
          2.minutes.ago => "OK_with_errors",
          5.minutes.ago => "OK",
          1.day.ago => "OK",
          3.days.ago => "Failure",
        }

        records.each do |start_time, status|
          FactoryBot.create(:pqa_import_run, start_time:, end_time: start_time + 3.seconds, status:)
        end

        expect(times_equal?(described_class.last_import_time_utc, 2.minutes.ago)).to be true
      end
    end
  end

  describe ".record_success" do
    it "records the times in UTC with an OK status" do
      freeze_time = Time.zone.local(2015, 5, 7, 10, 1, 33)
      Timecop.freeze(freeze_time) do
        described_class.record_success 10.seconds.ago, all_ok_report
      end
      pir = described_class.last
      expect(pir.start_time).to eq(freeze_time - 10.seconds)
      expect(pir.end_time).to eq(freeze_time)
      expect(pir.status).to eq "OK"
      expect(pir.num_created).to eq 15
      expect(pir.num_updated).to eq 3
      expect(pir.error_messages).to be_nil
    end

    it "records the times in UTC with an OK_with_errors status" do
      freeze_time = Time.zone.local(2015, 5, 7, 10, 1, 33)
      Timecop.freeze(freeze_time) do
        described_class.record_success 10.seconds.ago, ok_with_errors_report
      end
      pir = described_class.last
      expect(pir.start_time).to eq(freeze_time - 10.seconds)
      expect(pir.end_time).to eq(freeze_time)
      expect(pir.status).to eq "OK_with_errors"
      expect(pir.num_created).to eq 7
      expect(pir.num_updated).to eq 15
      expect(pir.error_messages).to eq({
        "UIN1234" => "Invalid Record",
        "UIN666" => "Really, really invalid",
      }.to_s)
    end
  end

  describe ".record_failure" do
    it "records the times in UTC with an error status" do
      freeze_time = Time.zone.local(2015, 5, 7, 10, 1, 33)
      Timecop.freeze(freeze_time) do
        described_class.record_failure 10.seconds.ago, "Unable to contact API endpoint"
      end
      pir = described_class.last
      expect(pir.start_time).to eq(freeze_time - 10.seconds)
      expect(pir.end_time).to eq(freeze_time)
      expect(pir.status).to eq "Failure"
      expect(pir.num_created).to eq 0
      expect(pir.num_updated).to eq 0
      expect(pir.error_messages).to eq "Unable to contact API endpoint"
    end
  end

  describe ".sum_pqs_imported" do
    let(:freeze_time) { Time.utc(2015, 5, 11, 9, 33, 45) }

    it "raises an exception if invalid argument given" do
      expect {
        described_class.sum_pqs_imported(:leap_year)
      }.to raise_error ArgumentError, "invalid range for sum_pqs_imported"
    end

    it "returns zero if there are no matching records" do
      FactoryBot.create(:pqa_import_run, start_time: 1.year.ago, end_time: 1.year.ago, num_created: 3, num_updated: 4)
      expect(described_class.sum_pqs_imported(:day)).to eq 0
      expect(described_class.sum_pqs_imported(:week)).to eq 0
      expect(described_class.sum_pqs_imported(:month)).to eq 0
    end

    it "returns appropriate figures" do
      Timecop.freeze(freeze_time) do
        # today
        FactoryBot.create(:pqa_import_run, start_time: 1.hour.ago, end_time: 1.hour.ago, num_created: 3, num_updated: 4)
        # today
        FactoryBot.create(:pqa_import_run, start_time: 2.hours.ago, end_time: 2.hours.ago, num_created: 2, num_updated: 5)
        # this week
        FactoryBot.create(:pqa_import_run, start_time: 25.hours.ago, end_time: 25.hours.ago, num_created: 3, num_updated: 4)
        # this week
        FactoryBot.create(:pqa_import_run, start_time: 72.hours.ago, end_time: 72.hours.ago, num_created: 3, num_updated: 4)
        # this week
        FactoryBot.create(:pqa_import_run, start_time: 9.days.ago, end_time: 9.days.ago, num_created: 23, num_updated: 14)
        # this week
        FactoryBot.create(:pqa_import_run, start_time: 10.days.ago, end_time: 10.days.ago, num_created: 35, num_updated: 7)

        expect(described_class.sum_pqs_imported(:day)).to eq 14
        expect(described_class.sum_pqs_imported(:week)).to eq 28
        expect(described_class.sum_pqs_imported(:month)).to eq 107
      end
    end
  end

  describe ".ready_for_early_bird" do
    it "returns true when last import was today and valid" do
      # today, valid
      FactoryBot.create(:pqa_import_run, start_time: 1.hour.ago, end_time: 1.hour.ago, num_created: 3, num_updated: 4, status: "OK")
      expect(described_class.ready_for_early_bird).to be true
    end

    it "returns false when last import was not today" do
      # yesterday, valid
      FactoryBot.create(:pqa_import_run, start_time: 1.day.ago, end_time: 1.hour.ago, num_created: 3, num_updated: 4, status: "OK")
      expect(described_class.ready_for_early_bird).to be false
    end

    it "returns false when last import was not valid" do
      # today, failed
      FactoryBot.create(:pqa_import_run, start_time: 1.hour.ago, end_time: 1.hour.ago, num_created: 3, num_updated: 4, status: "Failure")
      expect(described_class.ready_for_early_bird).to be false
    end

    it "returns false when last import was OK_with_errors" do
      # today, failed
      FactoryBot.create(:pqa_import_run, start_time: 1.hour.ago, end_time: 1.hour.ago, num_created: 3, num_updated: 4, status: "OK_with_errors")
      expect(described_class.ready_for_early_bird).to be false
    end
  end
end

def times_equal?(time1, time2)
  time1.to_f.round(2) == time2.to_f.round(2)
end

def all_ok_report
  {
    total: 18,
    created: 15,
    updated: 3,
    errors: {},
  }
end

def ok_with_errors_report
  {
    total: 22,
    created: 7,
    updated: 15,
    errors: {
      "UIN1234" => "Invalid Record",
      "UIN666" => "Really, really invalid",
    },
  }
end
