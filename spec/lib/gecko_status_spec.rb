require 'spec_helper'

describe GeckoStatus do
  let(:status) { GeckoStatus.new('Test') }

  it '#initialize - should set the component name and initial state' do
    expect(status.name).to eq 'Test'
    expect(status.label).to eq 'n/a'
    expect(status.color).to eq 'red'
    expect(status.message).to eq 'unitialized'
  end

  it '#warn - updates the status with a warning message' do
    status.warn('warning')

    expect(status.label).to eq 'WARNING'
    expect(status.color).to eq 'yellow'
    expect(status.message).to eq 'warning'
  end

  it '#error - updates the status with an error message' do
    status.error('error')

    expect(status.label).to eq 'ERROR'
    expect(status.color).to eq 'red'
    expect(status.message).to eq 'error'
  end

  it '#ok - updates the status with an ok message' do
    status.ok

    expect(status.label).to eq 'OK'
    expect(status.color).to eq 'green'
    expect(status.message).to eq ''
  end
end

describe KeyMetricStatus do
  let(:key_metric)  { double Metrics::KeyMetric                   }
  let(:metrics)     { double 'metrics', key_metric: key_metric    }
  let(:status)      { KeyMetricStatus.new                         }

  context '#update' do
    it 'calls ok when there is no alert' do
      allow(key_metric).to receive(:alert).and_return(false)

      expect(status).to receive(:ok)
      status.update(metrics)
    end

    it 'calls error when there is an alert' do
      allow(key_metric).to receive(:alert).and_return(true)
      
      expect(status).to receive(:error)
      status.update(metrics)
    end
  end
end

describe DbStatus do
  let(:health)   { Metrics::Health.new                }
  let(:metrics)  { double 'metrics', health: health   }
  let(:status)   { DbStatus.new                       }

  context '#update' do
    it 'calls ok when the db status is OK' do
      allow(health).to receive(:db_status).and_return(true)

      expect(status).to receive(:ok)
      status.update(metrics)
    end

    it 'calls error when there is a DB error' do
      allow(health).to receive(:db_status).and_return(false)
      
      expect(status).to receive(:error)
      status.update(metrics)
    end
  end
end

describe SendgridStatus do
  let(:health)   { Metrics::Health.new                }
  let(:metrics)  { double 'metrics', health: health   }
  let(:status)   { SendgridStatus.new                 }

  context '#update' do
    it 'calls ok when the sendgrid status is OK' do
      allow(health).to receive(:sendgrid_status).and_return(true)

      expect(status).to receive(:ok)
      status.update(metrics)
    end

    it 'calls error when there is a Send Grid error' do
      allow(health).to receive(:sendgrid_status).and_return(false)
      
      expect(status).to receive(:error)
      status.update(metrics)
    end
  end
end

describe PqaApiStatus do
  let(:health)   { Metrics::Health.new                   }
  let(:metrics)  { double 'metrics', health: health      }
  let(:status)   { PqaApiStatus.new                      }

  context '#update' do
    it 'calls ok when the PQA API status is OK' do
      allow(health).to receive(:pqa_api_status).and_return(true)

      expect(status).to receive(:ok)
      status.update(metrics)
    end

    it 'calls error when there is a PQA API error' do
      allow(health).to receive(:pqa_api_status).and_return(false)
      
      expect(status).to receive(:error)
      status.update(metrics)
    end
  end
end

describe MailStatus do
  let(:mail_info) { Metrics::Mail.new                           }
  let(:metrics)   { double 'metrics', mail: mail_info           }
  let(:status)    { MailStatus.new                              }

  context '#update' do
    it 'calls ok when there is no alert' do
      allow(mail_info).to receive(:email_error?).and_return(false)
      allow(mail_info).to receive(:token_error?).and_return(false)

      expect(status).to receive(:ok)
      status.update(metrics)
    end

    it 'calls error when there is a email error' do
      allow(mail_info).to receive(:email_error?).and_return(true)
      
      expect(status).to receive(:error)
      status.update(metrics)
    end

    it 'calls warn when there is a token error' do
      allow(mail_info).to receive(:email_error?).and_return(false)
      allow(mail_info).to receive(:token_error?).and_return(true)
      
      expect(status).to receive(:warn)
      status.update(metrics)
    end
  end
end

describe PqaImportStatus do
  let(:info)     { Metrics::PqaImport.new                      }
  let(:metrics)  { double 'metrics', pqa_import: info          }
  let(:status)   { PqaImportStatus.new                         }

  context '#update' do
    it 'calls ok when there are no issues' do
      allow(info).to receive(:last_run_time).and_return(Time.now)
      allow(info).to receive(:last_run_status).and_return('OK')

      expect(status).to receive(:ok)
      status.update(metrics)
    end

    it 'calls warn when the import is stale' do
      allow(info).to receive(:last_run_time).and_return(2.days.ago)
      allow(info).to receive(:last_run_status).and_return('OK')

      expect(status).to receive(:warn)
      status.update(metrics)
    end

    it 'calls error when the run_status is not OK' do
      allow(info).to receive(:last_run_time).and_return(Time.now)
      allow(info).to receive(:last_run_status).and_return('Bad')

      expect(status).to receive(:error)
      status.update(metrics)
    end
  end
end

describe SmokeTestStatus do
  let(:info)     { Metrics::SmokeTests.new                     }
  let(:metrics)  { double 'metrics', smoke_tests: info         }
  let(:status)   { SmokeTestStatus.new                         }

  context '#update' do
    it 'calls ok when there are no issues' do
      allow(info).to receive(:run_time).and_return(Time.now)
      allow(info).to receive(:run_success?).and_return(true)

      expect(status).to receive(:ok)
      status.update(metrics)
    end

    it 'calls warn when the test run is stale' do
      allow(info).to receive(:run_time).and_return(2.days.ago)
      allow(info).to receive(:run_success?).and_return(true)

      expect(status).to receive(:warn)
      status.update(metrics)
    end

    it 'calls error when the test run has failures' do
      allow(info).to receive(:run_time).and_return(Time.now)
      allow(info).to receive(:run_success?).and_return(false)

      expect(status).to receive(:error)
      status.update(metrics)
    end
  end
end
