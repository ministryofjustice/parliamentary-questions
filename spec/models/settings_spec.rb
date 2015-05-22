require 'spec_helper'

describe Settings do
  before(:each) do
    ENV['PQ_REST_API_HOST']     = 'api_host'
    ENV['PQ_REST_API_USERNAME'] = 'username'
    ENV['PQ_REST_API_PASSWORD'] = 'password'
  end

  context 'PQ Rest API' do
    describe '.from_env' do 
      it 'should call new with environment variables' do
        expect(Settings::PqRestApi).to receive(:new).with('api_host', 'username', 'password')
        Settings::PqRestApi.from_env
      end

      it 'should raise if the api-host environment var is not set' do
        ENV['PQ_REST_API_HOST'] = nil
        expect {
          Settings::PqRestApi.from_env
          }.to raise_error RuntimeError, 'Cannot find environment variable PQ_REST_API_HOST. Please set it first'
      end
    end
  end

  context 'settings file values' do
    describe '.live_url' do
      it 'should return the value from the file' do
        expect(Settings.live_url).to eq 'https://trackparliamentaryquestions.service.gov.uk'
      end
    end

    describe '.mail_from' do
      it 'should return the value from the file' do
        expect(Settings.mail_from).to eq 'PQ Team <no-reply@trackparliamentaryquestions.service.gov.uk>'
      end
    end

    describe '.mail_reply_to' do
      it 'should return the value from the file' do
        expect(Settings.mail_reply_to).to eq 'pqs@justice.gsi.gov.uk'
      end
    end

    describe '.mail_tech_support' do
      it 'should return the value from the file' do
        expect(Settings.mail_tech_support).to eq 'pqsupport@digital.justice.gov.uk'
      end
    end

    describe '.http_client_timeout' do
      it 'should return the value from the file' do
        expect(Settings.http_client_timeout).to eq 20
      end
    end

    describe '.commission_mail_from' do
      it 'should return the value from the file' do
        expect(Settings.commission_mail_from).to eq 'PQ Team <no-reply@trackparliamentaryquestions.service.gov.uk>'
      end
    end

    describe 'non existent config key' do
      it 'should raise NoMethodError' do
        expect {
          Settings.unknown_config_key
        }.to raise_error NoMethodError, "undefined method `unknown_config_key' for Settings:Module"
      end
    end

    describe '.excepted_from_ssl' do
      it 'should return an array from the file' do
        expect(Settings.excepted_from_ssl).to eq ['ping.json']
      end
    end

    describe '.key_metric_threshold' do
      it 'should return the value from the file' do
        expect(Settings.key_metric_threshold).to eq 0.5
      end
    end
  end

  context 'MailWorker' do
    describe '.pid_filepath' do
      it 'should return the value from the file' do
        expect(Settings.mail_worker.pid_filepath).to eq '/tmp/mail_worker.pid'
      end
    end

    describe '.max_fail_count' do
      it 'should return the value from the file' do
        expect(Settings.mail_worker.max_fail_count).to eq 15
      end
    end

    describe '.timeout' do
      it 'should return the value from the file' do
        expect(Settings.mail_worker.timeout).to eq 300
      end
    end
  end

  context 'Gecko Warning Levels' do
    it 'should return the values in the file' do
      expect(Settings.gecko_warning_levels.num_emails_waiting).to eq 15
      expect(Settings.gecko_warning_levels.num_emails_abandoned).to eq 1
      expect(Settings.gecko_warning_levels.pctg_answered_tokens).to eq 50
    end
  end

  context 'Smoke Test Runner' do
    describe '.out_file' do
      it 'should return the value in the file' do
        expect(Settings.smoke_test_runner.out_file).to eq '/tmp/smoke_test_run'
      end
    end
  end
end
