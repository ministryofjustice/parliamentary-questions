require 'spec_helper'

describe MetricsDashboard do

  let(:metrics)       {  MetricsDashboard.new }

  describe 'gather_metrics' do
    context 'health' do
      context 'database' do
        
        before(:each) do
          @checker = double HealthCheck::Database
          expect(HealthCheck::Database).to receive(:new).and_return(@checker)
        end

        it 'should return true for database access if accessible' do
          expect(@checker).to receive(:accessible?).and_return(true)
          expect(@checker).to receive(:available?).and_return(true)

          metrics.send(:gather_health_metrics)
          expect(metrics.health.db_status).to be true
        end

        it 'should return false for database acess if inaccessible' do
          expect(@checker).to receive(:accessible?).and_return(true)
          expect(@checker).to receive(:available?).and_return(false)

          metrics.send(:gather_health_metrics)
          expect(metrics.health.db_status).to be false
        end
      end

      context 'sendgrid' do
        
        before(:each) do
          @checker = HealthCheck::SendGrid.new
          expect(HealthCheck::SendGrid).to receive(:new).and_return(@checker)
        end

        it 'should return true if sendgrid both accessible and available' do
          expect(@checker).to receive(:accessible?).and_return(true)
          expect(@checker).to receive(:available?).and_return(true)
          metrics.send(:gather_health_metrics)
          expect(metrics.health.sendgrid_status).to be true
        end
        
        it 'should return false if sendgrid not available' do
          expect(@checker).to receive(:accessible?).and_return(true)
          expect(@checker).to receive(:available?).and_return(false)
          metrics.send(:gather_health_metrics)
          expect(metrics.health.sendgrid_status).to be false
        end
        

        it 'should return false if sendgrid.available? raises an error' do
          expect(@checker).to receive(:accessible?).and_return(true)
          expect(Net::SMTP).to receive(:start).and_raise(RuntimeError.new("Something's gone wrong"))
          metrics.send(:gather_health_metrics)
          expect(metrics.health.sendgrid_status).to be false
        end

        it 'should return false if sendgrid not accessible' do
          expect(@checker).to receive(:accessible?).and_return(false)
          expect(@checker).not_to receive(:available?)
          metrics.send(:gather_health_metrics)
          expect(metrics.health.sendgrid_status).to be false
        end
        
        it 'should reutrn false if sendgrid.accessible? raises an error' do
          expect(Net::SMTP).to receive(:start).and_raise(RuntimeError.new("Something's gone wrong"))
          metrics.send(:gather_health_metrics)
          expect(metrics.health.sendgrid_status).to be false
        end
      end


      context 'pqa_api' do
        it 'should return false if file doesnt exist' do
          File.unlink HealthCheck::PqaApi::TIMESTAMP_FILE if File.exist?(HealthCheck::PqaApi::TIMESTAMP_FILE)
          metrics.send(:gather_health_metrics)
          expect(metrics.health.pqa_api_status).to be false
        end

        it 'should return false if timestamp of file is more than settings healthcheck_pqa_api_interval + 5 minutes' do
          interval = Settings.healthcheck_pqa_api_interval
          unixtimestamp = (interval + 5).minutes.ago.utc.to_i
          write_pqa_file(unixtimestamp, 'OK', [])
          metrics.send(:gather_health_metrics)
          expect(metrics.health.pqa_api_status).to be false
        end

        it 'should return false if status in timestamp file not OK' do
          interval = Settings.healthcheck_pqa_api_interval
          unixtimestamp = (interval - 2).minutes.ago.utc.to_i
          write_pqa_file(unixtimestamp, 'FAIL', [])
          metrics.send(:gather_health_metrics)
          expect(metrics.health.pqa_api_status).to be false
        end

        it 'should return true if everything ok' do
          interval = Settings.healthcheck_pqa_api_interval
          unixtimestamp = (interval - 2).minutes.ago.utc.to_i
          write_pqa_file(unixtimestamp, 'OK', [])
          metrics.send(:gather_health_metrics)
          expect(metrics.health.pqa_api_status).to be true
        end

      end
    end

    context 'app_info' do
      it 'should return whatever Deployment gives it' do
        expect(Deployment).to receive(:info).and_return(deployment_info)
        metrics.send(:gather_app_info_metrics)
        expect(metrics.app_info.version).to eq '9.88.77'
        expect(metrics.app_info.build_date).to eq 'Mon May 11 15:45:09 UTC 2015'
        expect(metrics.app_info.git_sha).to eq '00112233445566778899aabbccddeeff'
        expect(metrics.app_info.build_tag).to eq 'jenkins-build-release-666'
      end
    end

    context 'mail_info_metrics' do
      context 'email records' do

        before(:each) { setup_mail_records }

        it 'should return the number of new and failed mails' do
          metrics.send(:gather_mail_info_metrics)
          expect(metrics.mail.num_waiting).to eq 4
        end

        it 'should return the number of abandoned mails' do
          metrics.send(:gather_mail_info_metrics)
          expect(metrics.mail.num_abandoned).to eq 1
        end
      end

      it 'should return the dummy number of tokens until this is correctly implemented' do
        metrics.send(:gather_mail_info_metrics)
        expect(metrics.mail.num_unanswered_tokens).to eq 666
      end

    end

    context 'pqa_import_metrics' do
      it 'should return time of last run in BST during summer' do
        Timecop.freeze(2015, 5, 15, 13, 45, 5) do
          FactoryGirl.create :pqa_import_run, start_time: Time.now
          metrics.send(:gather_pqa_import_metrics)
          expect(metrics.pqa_import.last_run_time.iso8601).to eq '2015-05-15T14:45:05+01:00'
        end
      end

      it 'should return time of last run in UTC during winter' do
        Timecop.freeze(2014, 12, 25, 13, 45, 5) do
          FactoryGirl.create :pqa_import_run, start_time: Time.now
          metrics.send(:gather_pqa_import_metrics)
          expect(metrics.pqa_import.last_run_time.iso8601).to eq '2014-12-25T13:45:05+00:00'
        end
      end

      it 'should return ok status if last run was ok' do
        FactoryGirl.create :pqa_import_run, start_time: Time.now
        metrics.send(:gather_pqa_import_metrics)
        expect(metrics.pqa_import.last_run_status).to eq 'OK'
      end

      it 'should return fail status if last run was not ok' do
        FactoryGirl.create :pqa_import_run, start_time: Time.now, status: 'OK_with_errors'
        metrics.send(:gather_pqa_import_metrics)
        expect(metrics.pqa_import.last_run_status).to eq 'OK_with_errors'
      end

      it 'should return values given to it by PqaImportRun' do
        FactoryGirl.create :pqa_import_run, start_time: Time.now
        expect(PqaImportRun).to receive(:sum_pqs_imported).with(:day).and_return(25)
        expect(PqaImportRun).to receive(:sum_pqs_imported).with(:week).and_return(133)
        expect(PqaImportRun).to receive(:sum_pqs_imported).with(:month).and_return(402)
        metrics.send(:gather_pqa_import_metrics)
        expect(metrics.pqa_import.pqs.today).to eq 25
        expect(metrics.pqa_import.pqs.this_week).to eq 133
        expect(metrics.pqa_import.pqs.this_month).to eq 402
      end
    end


  end
end



def write_pqa_file(timestamp, status, messages)
  File.open(HealthCheck::PqaApi::TIMESTAMP_FILE, 'w') do |fp|
    fp.puts("#{timestamp}::#{status}::#{messages.to_json}")
  end
end


def deployment_info
  {
    version_number: "9.88.77",
    build_date: "Mon May 11 15:45:09 UTC 2015",
    commit_id: "00112233445566778899aabbccddeeff",
    build_tag: "jenkins-build-release-666"
  }
end

def setup_mail_records
  3.times { FactoryGirl.create :pq_email_new }
  2.times { FactoryGirl.create :pq_email_sent }
  FactoryGirl.create :pq_email_abandoned
  FactoryGirl.create :pq_email_failed

end

