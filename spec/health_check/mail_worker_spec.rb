require 'feature_helper'

describe HealthCheck::MailWorker do
  let(:pid_path)  { Settings.mail_worker.pid_filepath }
  let(:worker)    { HealthCheck::MailWorker.new       }
  let(:mail)      { double Email, status: 'abandoned' }

  context '#available?' do
    it 'returns true if the mail worker is available' do
      expect(worker).to be_available
    end

    it 'returns false if the mail worker is not available' do
      expect(File).to receive(:exists?).with(pid_path).and_return(true)
      expect(File).to receive(:ctime).with(pid_path).and_return(Date.yesterday)

      expect(worker).not_to be_available
    end
  end

  context '#accessible?' do
    it 'returns true if the mail service is accessible and no emails are abandoned' do
      expect(worker).to be_accessible
    end

    it 'returns false if the mail service is not accessible' do
      allow(MailService).to receive(:abandoned_mail).and_raise(RuntimeError)

      expect(worker).not_to be_accessible
    end

    it 'returns false if there are abandoned emails' do
      allow(MailService).to receive(:abandoned_mail).and_return([mail])
      
      expect(worker).not_to be_accessible
    end
  end

  context '#error_messages' do
    it 'returns the exception messages if the pid file is stale' do
      allow(worker).to receive(:stale_pid_file?).and_return(true)
      worker.available?

      expect(worker.error_messages).to eq [
        'MailWorker Timeout Error: mail queue process time > 300 seconds'
      ]
    end

    it 'returns the exception messages if emails have been abandoned' do
      allow(MailService).to receive(:abandoned_mail).and_return([mail])
      worker.accessible?

      expect(worker.error_messages).to eq [
        'MailWorker Mail Service Error: 1 email(s) abandoned'
      ]
    end

    it 'returns an error an backtrace for errors not specific to a component' do
      allow(worker).to receive(:stale_pid_file?).and_raise(StandardError)
      worker.available?

      expect(worker.error_messages.first).to match /Error: StandardError\nDetails/
    end
  end
end