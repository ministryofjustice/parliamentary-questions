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

require 'spec_helper'


describe PqaImportRun, :type => :model do
  
  context 'validation' do

    it 'should error if status is not ok or failure or ok_with_errors' do
      pir = FactoryGirl.build(:pqa_import_run, status: 'gobbledygook')
      expect(pir).not_to be_valid
      expect(pir.errors[:status]).to eq ["Status must be 'OK', 'Failure' or 'OK_with_errors': was 'gobbledygook'"]
    end

    it 'should not error if status ok' do
      pir = FactoryGirl.build(:pqa_import_run)
      expect(pir).to be_valid
    end

    it 'should not error is status failure' do
      pir = FactoryGirl.build(:pqa_import_run, status: "Failure")
      expect(pir).to be_valid
    end

    it 'should not error is status ok_with_errors' do
      pir = FactoryGirl.build(:pqa_import_run, status: "OK_with_errors")
      expect(pir).to be_valid
    end

  end


  describe '.last_import_time_utc' do
    it 'should return start of epoch if no records in the database' do
      Timecop.freeze(Time.new(2015, 5, 7, 11, 15, 45)) do
        expect(PqaImportRun.count).to eq 0
        expect(PqaImportRun.last_import_time_utc).to eq(3.days.ago)
        expect(PqaImportRun.last_import_time_utc.zone).to eq 'UTC'
      end
    end

    it 'should return the start time of the last record' do
      times = [  10.seconds.ago, 1.day.ago, 2.days.ago ]
      latest_time = times.first

      times.each { |t| FactoryGirl.create(:pqa_import_run, start_time: t, end_time: t + 3.seconds) }
      expect(times_equal?(PqaImportRun.last_import_time_utc, latest_time)).to be true
      expect(PqaImportRun.last_import_time_utc.zone).to eq 'UTC'
    end

    it 'should ignore failure records' do
      Timecop.freeze do
        records = {
          10.seconds.ago  => 'Failure',
          2.minutes.ago   => 'OK_with_errors',
          5.minutes.ago   => 'OK',
          1.day.ago       => 'OK',
          3.days.ago      => 'Failure'}

        records.each do |start_time, status|
          FactoryGirl.create(:pqa_import_run, start_time: start_time, end_time: start_time + 3.seconds, status: status)
        end

        expect(times_equal?(PqaImportRun.last_import_time_utc, 2.minutes.ago)).to be true
      end
    end

  end


  describe '.record_success' do
    it 'should record the times in UTC with an OK status' do
      freeze_time = Time.new(2015, 5, 7, 10, 1, 33)
      Timecop.freeze(freeze_time) do
        PqaImportRun.record_success 10.seconds.ago, all_ok_report
      end
      pir = PqaImportRun.last
      expect(pir.start_time).to eq(freeze_time - 10.seconds)
      expect(pir.end_time).to eq(freeze_time)
      expect(pir.status).to eq 'OK'
      expect(pir.num_created).to eq 15
      expect(pir.num_updated).to eq 3
      expect(pir.error_messages).to be_nil
    end


    it 'should record the times in UTC with an OK_with_errors status' do
      freeze_time = Time.new(2015, 5, 7, 10, 1, 33)
      Timecop.freeze(freeze_time) do
        PqaImportRun.record_success 10.seconds.ago, ok_with_errors_report
      end
      pir = PqaImportRun.last
      expect(pir.start_time).to eq(freeze_time - 10.seconds)
      expect(pir.end_time).to eq(freeze_time)
      expect(pir.status).to eq 'OK_with_errors'
      expect(pir.num_created).to eq 7
      expect(pir.num_updated).to eq 15
      expect(pir.error_messages).to eq( {"UIN1234" => "Invalid Record", "UIN666" => "Really, really invalid"} )
    end
  end


  describe '.record_failure' do
    it 'should record the times in UTC with an error status' do
      freeze_time = Time.new(2015, 5, 7, 10, 1, 33)
      Timecop.freeze(freeze_time) do
        PqaImportRun.record_failure 10.seconds.ago, 'Unable to contact API endpoint'
      end
      pir = PqaImportRun.last
      expect(pir.start_time).to eq(freeze_time - 10.seconds)
      expect(pir.end_time).to eq(freeze_time)
      expect(pir.status).to eq 'Failure'
      expect(pir.num_created).to eq 0
      expect(pir.num_updated).to eq 0
      expect(pir.error_messages).to eq 'Unable to contact API endpoint'
    end
  end




  describe '.sum_pqs_imported' do
    let(:freeze_time)      { Time.utc(2015, 5, 11, 9, 33, 45) }

    it 'should raise an exception if invalid argument given' do
      expect {
        PqaImportRun.sum_pqs_imported(:leap_year)
      }.to raise_error ArgumentError, 'invalid range for sum_pqs_imported'
    end


    it 'should return zero if there are no matching records' do
      FactoryGirl.create(:pqa_import_run, start_time: 1.year.ago, end_time: 1.year.ago, num_created: 3, num_updated: 4 )
      expect(PqaImportRun.sum_pqs_imported(:day)).to eq 0
      expect(PqaImportRun.sum_pqs_imported(:week)).to eq 0
      expect(PqaImportRun.sum_pqs_imported(:month)).to eq 0
    end

    it 'should return appropriate figures' do
      Timecop.freeze(freeze_time) do
        FactoryGirl.create(:pqa_import_run, start_time: 1.hour.ago, end_time: 1.hour.ago, num_created: 3, num_updated: 4 )       # today
        FactoryGirl.create(:pqa_import_run, start_time: 2.hours.ago, end_time: 2.hours.ago, num_created: 2, num_updated: 5 )     # today
        FactoryGirl.create(:pqa_import_run, start_time: 25.hours.ago, end_time: 25.hours.ago, num_created: 3, num_updated: 4 )   # this week
        FactoryGirl.create(:pqa_import_run, start_time: 72.hour.ago, end_time: 72.hour.ago, num_created: 3, num_updated: 4 )     # this week
        FactoryGirl.create(:pqa_import_run, start_time: 9.days.ago, end_time: 9.days.ago, num_created: 23, num_updated: 14 )     # this week
        FactoryGirl.create(:pqa_import_run, start_time: 10.days.ago, end_time: 10.days.ago, num_created: 35, num_updated: 7 )     # this week
    
        expect(PqaImportRun.sum_pqs_imported(:day)).to eq 14
        expect(PqaImportRun.sum_pqs_imported(:week)).to eq 28
        expect(PqaImportRun.sum_pqs_imported(:month)).to eq 107
      end
    end
  end
end


def times_equal?(t1, t2)
  t1.to_f.round(2) == t2.to_f.round(2)
end



def all_ok_report
  {
    total:    18,
    created:  15,
    updated:  3,
    errors:   {}
  }
end


def ok_with_errors_report
  {
    total:    22,
    created:  7,
    updated:  15,
    errors:   {
      "UIN1234" => "Invalid Record",
      "UIN666" => "Really, really invalid"
    }
  }
end
