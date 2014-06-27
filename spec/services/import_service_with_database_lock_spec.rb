require 'spec_helper'

describe 'ImportServiceWithDatabaseLock' do
  progress_seed

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
      logs[0].log_type.should eq('START')
      logs[1].log_type.should eq('SUCCESS')
      logs[2].log_type.should eq('SUCCESS')
      logs[3].log_type.should eq('FINISH')

    end


    it 'should prevent that multiple execution run at the same time' do

      result = @import_service.questions()
      result[:log_type].should eq('FINISH')

      result = @import_service.questions()

      result[:log_type].should eq('SKIP_RUN')
      result[:msg].should eq('other process is running')

    end


    it 'should cleanup older results' do

      ImportLog.create(log_type: 'TEST', msg: 'test', created_at: DateTime.now - 5.days)
      ImportLog.create(log_type: 'TEST', msg: 'test', created_at: DateTime.now - 5.days)
      ImportLog.create(log_type: 'TEST', msg: 'test', created_at: DateTime.now - 5.days)

      result = @import_service.questions()
      result[:log_type].should eq('FINISH')

      ImportLog.where('log_type = ?', 'TEST').count.should eq(0)

    end


  end
end
