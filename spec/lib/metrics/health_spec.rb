require 'spec_helper'

describe Metrics::Health do
  context '#collect!' do
    context 'DB' do
      before(:each) do
        allow(subject).to receive(:get_sendgrid_status).and_return(true)
        allow(subject).to receive(:get_pqa_api_status).and_return(true)
      end

      it 'should set the db status to false if the db is not available' do
        allow_any_instance_of(HealthCheck::Database).to receive(:accessible?).and_return(false)
        subject.collect!

        expect(subject.db_status).to eq false
      end

      it 'should set the db status to false if the db is not accessible' do
        allow_any_instance_of(HealthCheck::Database).to receive(:accessible?).and_return(true)
        allow_any_instance_of(HealthCheck::Database).to receive(:available?).and_return(false)
        subject.collect!

        expect(subject.db_status).to eq false
      end

      it 'should set the db status to true otherwise' do
        allow_any_instance_of(HealthCheck::Database).to receive(:accessible?).and_return(true)
        allow_any_instance_of(HealthCheck::Database).to receive(:available?).and_return(true)
        subject.collect!

        expect(subject.db_status).to eq true
      end
    end

    context 'SendGrid' do
      before(:each) do
        allow(subject).to receive(:get_db_status).and_return(true)
        allow(subject).to receive(:get_pqa_api_status).and_return(true)
      end

      it 'should set the sendgrid status to false if sendgrid is not available' do
        allow_any_instance_of(HealthCheck::SendGrid).to receive(:accessible?).and_return(false)
        subject.collect!

        expect(subject.sendgrid_status).to eq false
      end

      it 'should set the sendgrid status to false if sendgrid is not accessible' do
        allow_any_instance_of(HealthCheck::SendGrid).to receive(:accessible?).and_return(true)
        allow_any_instance_of(HealthCheck::SendGrid).to receive(:available?).and_return(false)
        subject.collect!

        expect(subject.sendgrid_status).to eq false
      end

      it 'should set the sendgrid status to true otherwise' do
        allow_any_instance_of(HealthCheck::SendGrid).to receive(:accessible?).and_return(true)
        allow_any_instance_of(HealthCheck::SendGrid).to receive(:available?).and_return(true)
        subject.collect!

        expect(subject.sendgrid_status).to eq true
      end
    end

    context 'PQA API' do
      let(:pqa_file) { Metrics::Health::PqaFile }
      let(:pqa_data) {  "1431099345::OK::[]\n"  }

      before(:each) do
        allow(subject).to receive(:get_db_status).and_return(true)
        allow(subject).to receive(:get_sendgrid_status).and_return(true)
      end

      def set_properties(exists, stale, status)
        allow(File).to receive(:exists?).and_return(exists)
        allow(File).to receive(:read).and_return(pqa_data)
        allow_any_instance_of(pqa_file).to receive(:stale?).and_return(stale)
        allow_any_instance_of(pqa_file).to receive(:status).and_return(status)
      end

      it 'should set the pqa api status to false if the api status check is not OK' do        
        set_properties(true, false, 'Not OK')
        subject.collect!

        expect(subject.pqa_api_status).to eq false
      end

      it 'should set the pqa api status to false if the api status check timestamp file is not present' do
        set_properties(false, false, 'OK')
        subject.collect!

        expect(subject.pqa_api_status).to eq false
      end

      it 'should set the pqa api status to false if the api status check timestamp is not up to date' do
        allow_any_instance_of(pqa_file).to receive(:exists?).and_return(true)
        allow_any_instance_of(pqa_file).to receive(:last_run_time).and_return(2.days.ago)
        allow_any_instance_of(pqa_file).to receive(:status).and_return('OK')
        subject.collect!

        expect(subject.pqa_api_status).to eq false
      end

      it 'should set the pqa api status to true otherwise' do
        set_properties(true, false, 'OK')
        subject.collect!

        expect(subject.pqa_api_status).to eq true
      end
    end
  end
end