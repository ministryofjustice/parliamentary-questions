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
  end
end



def write_pqa_file(timestamp, status, messages)
  File.open(HealthCheck::PqaApi::TIMESTAMP_FILE, 'w') do |fp|
    fp.puts("#{timestamp}::#{status}::#{messages.to_json}")
  end
end


