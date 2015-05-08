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





    end
  end
end