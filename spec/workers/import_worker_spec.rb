require 'spec_helper'

describe ImportWorker do
  let(:worker)              { ImportWorker.new                        }
  let(:importer)            { worker.instance_variable_get(:@import)  }
  let(:freeze_time)         { Time.new(2015, 5, 7, 12, 45, 17).utc    }
  let(:last_import_time)    { Time.new(2015, 7, 9, 8, 30, 26).utc     }
  let(:five_mins_from_now)  { Time.new(2015, 5, 7, 12, 50, 17).utc    }
  let(:three_days_ago)      { Time.new(2015, 5, 4, 12, 45, 17).utc    }

  let(:ok_report) do
    {
      total: 18,
      created: 15,
      updated: 3,
      errors: {}
    }
  end

  describe '#perform' do
    it 'should record collect questions from 3 days ago if the pqa_import_runs table is empty' do
      allow(NotifyImportMailer).to receive_message_chain(:notify_success, :deliver_now)
      Timecop.freeze freeze_time do
        expect(PqaImportRun.count).to eq(0)
        expect(importer).to receive(:run).with(three_days_ago, five_mins_from_now).and_return(ok_report)

        worker.perform
      end
    end

    it 'should collect questions from the start time of the previous import' do
      allow(NotifyImportMailer).to receive_message_chain(:notify_success, :deliver_now)
      Timecop.freeze freeze_time do
        allow(PqaImportRun).to receive(:last_import_time_utc).and_return(last_import_time)
        expect(importer).to receive(:run).with(last_import_time, five_mins_from_now).and_return(ok_report)

        worker.perform
      end
    end

    it 'should add a record to the pqa_runs_table with the time of running' do
      allow(NotifyImportMailer).to receive_message_chain(:notify_success, :deliver_now)
      Timecop.freeze freeze_time do
        allow(PqaImportRun).to receive(:last_import_time_utc).and_return(last_import_time)
        expect(importer).to receive(:run).with(last_import_time, five_mins_from_now).and_return(ok_report)

        worker.perform
        pir = PqaImportRun.last
        expect(pir.start_time).to eq(freeze_time)
      end
    end
  end

  describe 'email motifications' do
    it 'should send a success email if the import completes' do
      allow(NotifyImportMailer).to receive_message_chain(:notify_success, :deliver_now)
      allow(importer).to receive(:run).and_return(ok_report)
      worker.perform

      expect(NotifyImportMailer).to have_received(:notify_success).with(ok_report)
    end

    it 'should send a failure notification email if the import does not complete' do
      allow(NotifyImportMailer).to receive_message_chain(:notify_fail, :deliver_now)
      allow(importer).to receive(:run).and_raise(Errno::ECONNREFUSED, 'details')
      worker.perform

      expect(NotifyImportMailer).to have_received(:notify_fail).with('Connection refused - details')
    end
  end
end
