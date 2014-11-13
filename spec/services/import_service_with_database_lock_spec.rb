require 'spec_helper'

describe 'ImportServiceWithDatabaseLock' do
  before(:each) do
    @http_client = double('QuestionsHttpClient')
    allow(@http_client).to receive(:questions) { import_questions_for_today }

    questions_service = QuestionsService.new(@http_client)
    import_service_plain = ImportService.new(questions_service)

    @import_service = ImportServiceWithDatabaseLock.new(import_service_plain)
  end

  describe '#questions' do
    it 'should log the activity on the database when process a question' do
      @import_service.questions()

      logs = ImportLog.all
      expect(logs[0].log_type).to eq('START')
      expect(logs[1].log_type).to eq('SUCCESS')
      expect(logs[2].log_type).to eq('SUCCESS')
      expect(logs[3].log_type).to eq('FINISH')
    end

    it 'should prevent that multiple execution run at the same time' do
      result = @import_service.questions()
      expect(result[:log_type]).to eq('FINISH')

      result = @import_service.questions()

      expect(result[:log_type]).to eq('SKIP_RUN')
    end

    it 'should cleanup older results' do
      ImportLog.create(log_type: 'TEST', msg: 'test', created_at: DateTime.now - 5.days)
      ImportLog.create(log_type: 'TEST', msg: 'test', created_at: DateTime.now - 5.days)
      ImportLog.create(log_type: 'TEST', msg: 'test', created_at: DateTime.now - 5.days)

      result = @import_service.questions()
      expect(result[:log_type]).to eq('FINISH')

      expect(ImportLog.where('log_type = ?', 'TEST').count).to eq(0)
    end
  end
end
