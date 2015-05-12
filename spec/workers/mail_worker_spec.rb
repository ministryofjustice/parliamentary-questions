require 'spec_helper' 

describe MailWorker do
  let(:worker)   { MailWorker.new            }
  let(:file)     { double File               }
  let(:pid_path) { MailWorker::PID_FILEPATH  }
  let!(:default) { create(:pq_email)         }
  let!(:sent)    { create(:pq_email_sent)    }
  let!(:failed)  { create(:pq_email_failed)  } 

  context '#run!' do
    it 'should send all eligible emails in the db' do
      expect(MailService).to receive(:send_mail).with(default)
      expect(MailService).to receive(:send_mail).with(failed)
      expect(MailService).not_to receive(:send_mail).with(sent)

      worker.run!
    end

    it 'should update the emails in the db as sent if there are no errors' do
      expect(MailService).to receive(:record_attempt).with(default)
      expect(MailService).to receive(:record_attempt).with(failed)

      expect(MailService).to receive(:record_success).with(default)
      expect(MailService).to receive(:record_success).with(failed)

      worker.run!
    end

    it 'should update the emails in the db as failed if there are errors' do
      allow(MailService).to receive(:send_mail).and_raise(RuntimeError)

      expect(MailService).to receive(:record_fail).with(default)
      expect(MailService).to receive(:record_fail).with(failed)

      worker.run!      
    end

    it 'should set the state of an email to abandoned if it fails to send repeatedly' do
      allow(MailService).to receive(:send_mail).with(default)
      allow(MailService).to receive(:send_mail).with(failed).and_raise(RuntimeError)

      (MailWorker::MAX_FAIL_COUNT + 1).times { worker.run! }
      
      expect(default.reload.status).not_to eq 'abandoned'
      expect(failed.reload.status).to eq 'abandoned'
    end
  end

  context 'PID file' do
    it 'should write a pid file on start' do
      expect(File).to receive(:open).with(pid_path, 'w').and_yield(file)
      expect(file).to receive(:write).with(Process.pid.to_s)

      worker.run!
    end

    it 'should not process emails and exit if another pid file is present' do
      allow(File).to receive(:open).with(pid_path).and_yield(file)
      allow(File).to receive(:exists?).with(pid_path).and_return(true)
      allow(File).to receive(:read).with(pid_path).and_return('xyz')

      expect(MailService).not_to receive(:send_mail)
      expect { worker.run! }.to raise_error(MailWorker::ExistingMailWorkerProcess)
    end

    it 'should clear the pid file on exit, even if an error occurs' do
      expect(File).to receive(:delete).with(pid_path).and_call_original

      worker.run!
    end

    it 'should clear the pid file even if an error occurs' do
      allow(MailService).to receive(:mail_to_send).and_raise(RuntimeError)
      
      expect(File).to receive(:delete).with(pid_path).and_call_original
      expect { worker.run! }.to raise_error(RuntimeError)
    end
  end
end