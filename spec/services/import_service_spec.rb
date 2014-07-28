require 'spec_helper'

describe 'ImportService' do
  progress_seed

  before(:each) do
    @http_client = double('QuestionsHttpClient')
    allow(@http_client).to receive(:questions) { import_questions_for_today }

    questions_service = QuestionsService.new(@http_client)
    @import_service = ImportService.new(questions_service)
  end

  describe '#questions_by_uin' do
    it 'should store the question into the data model' do
      allow(@http_client).to receive(:question) { import_questions_for_today }

      import_result = @import_service.questions_by_uin('HL784845')
      import_result[:questions].size.should eq(1)

      question_one = Pq.find_by(uin: 'HL784845')
      question_one.should_not be_nil
      question_one.raising_member_id.should eql(2479)
      question_one.question.should eql('Hello we are asking questions')

    end
  end


  describe '#today_questions' do
    it 'should store today questions into the data model' do
      import_result = @import_service.questions()
      import_result[:questions].size.should eq(2)

      # first question
      question_one = Pq.find_by(uin: 'HL784845')
      question_one.should_not be_nil
      question_one.raising_member_id.should eql(2479)
      question_one.question.should eql('Hello we are asking questions')

      question_one.member_name.should eql('Diana Johnson')
      question_one.member_constituency.should eql('Kingston upon Hull North')
      question_one.house_name.should eql('House of Lords')
      question_one.date_for_answer.strftime("%Y-%m-%d").should eql('2013-01-27')
      question_one.registered_interest.should eql(false)
      question_one.tabled_date.strftime("%Y-%m-%d").should eql('2013-01-22')

      question_one.internal_deadline.strftime("%Y-%m-%d %H:%M").should eql(Date.today.strftime("%Y-%m-%d 10:30"))

      question_one.question_type.should eql('NamedDay')
      question_one.preview_url.should eql ('https://wqatest.parliament.uk/Questions/Details/37988')

      question_one.transferred.should eq(false)

      question_one.question_status.should eq('Tabled')
      
      # second question
      question_two = Pq.find_by(uin: 'HL673892')
      question_two.should_not be_nil
      question_two.raising_member_id.should eql(9742)
      question_two.question.should eql("I'm asking questions too")
      question_two.internal_deadline.strftime("%Y-%m-%d %H:%M").should eql(Date.today.strftime("%Y-%m-%d 10:30"))

    end

    it 'should update the question data if #today_questions is called multiple times' do

      # First call
      import_result = @import_service.questions()
      import_result[:questions].size.should eq(2)

      question_one = Pq.find_by(uin: 'HL784845')
      question_one.should_not be_nil
      question_one.question.should eql('Hello we are asking questions')

      question_two = Pq.find_by(uin: 'HL673892')
      question_two.should_not be_nil
      question_two.question.should eql("I'm asking questions too")

      # Second call, with different xml response
      allow(@http_client).to receive(:questions) { import_questions_for_today_with_changes }

      @import_service.questions()

      question_one = Pq.find_by(uin: 'HL784845')
      question_one.should_not be_nil
      question_one.question.should eql('Hello we are asking questions')

      question_two = Pq.find_by(uin: 'HL673892')
      question_two.should_not be_nil
      # The question text is different now
      question_two.question.should eql("The Text Changed")

    end


    it 'should create new question, if you get new questions from the api' do

      # First call
      import_result = @import_service.questions()
      import_result[:questions].size.should eq(2)

      question_one = Pq.find_by(uin: 'HL784845')
      question_one.should_not be_nil
      question_one.question.should eql('Hello we are asking questions')

      question_two = Pq.find_by(uin: 'HL673892')
      question_two.should_not be_nil
      question_two.question.should eql("I'm asking questions too")

      question_new = Pq.find_by(uin: 'HL5151')
      question_new.should be_nil

      # Second call, with one new question
      allow(@http_client).to receive(:questions) { import_questions_for_today_with_changes }

      @import_service.questions()

      question_new = Pq.find_by(uin: 'HL5151')
      question_new.should_not be_nil
      question_new.question.should eql('New question in the api')

    end

    it 'should return error hash when sent malformed XML from api' do
      allow(@http_client).to receive(:questions) { import_questions_for_today_with_missing_uin }
      import_result = @import_service.questions()

      import_result[:questions].size.should eql(1)

      errors = import_result[:errors]
      errors.size.should eql(1)	  

      err = errors.first

	  err[:message].should eql(["Uin can't be blank"])
	  question_with_error = err[:question]

	  question_with_error['Text'].should eql("I'm asking questions too")
	  question_with_error['Uin'].should be_nil	  

    end

    it 'should not overwrite the question internal_deadline' do
      # First call
      import_result = @import_service.questions()
      import_result[:questions].size.should eq(2)

      question_one = Pq.find_by(uin: 'HL784845')
      question_one.should_not be_nil
      question_one.internal_deadline.strftime("%Y-%m-%d %H:%M").should eql(Date.today.strftime("%Y-%m-%d 10:30"))

      question_one.internal_deadline = DateTime.new(2012, 8, 29,  0,  0,  0)
      question_one.save()

      # Second call, should have the deadline saved, not the default one
      import_result = @import_service.questions()
      question_one = Pq.find_by(uin: 'HL784845')
      question_one.should_not be_nil
      question_one.internal_deadline.strftime("%Y-%m-%d %H:%M").should eql("2012-08-29 00:00")

    end


    it 'should create the question in Unallocated state' do
      import_result = @import_service.questions()
      import_result[:questions].size.should eq(2)

      question_one = Pq.find_by(uin: 'HL784845')
      question_one.should_not be_nil

      question_one.progress.name.should eq(Progress.UNASSIGNED)

    end


    it 'should move questions from Accepted to Draft Pending' do

      # setup a pq accepted that needs to move from Accepted to Draft Pending
      pq = create(:Pq, uin: 'PQ_TO_MOVE', question: 'test question?', progress_id: Progress.accepted.id)
      ao = create(:action_officer, name: 'ao name 1', email: 'ao@ao.gov')
      yesterday = DateTime.now - 1.day
      ActionOfficersPq.create(action_officer_id: ao.id, pq_id: pq.id, accept: true, reject: false, updated_at: yesterday)

      # setup a pq accepted that does need to move it
      pq = create(:Pq, uin: 'PQ_TO_STAY', question: 'test question?', progress_id: Progress.accepted.id)
      ActionOfficersPq.create(action_officer_id: ao.id, pq_id: pq.id, accept: true, reject: false, updated_at: DateTime.now)

      import_result = @import_service.questions()
      import_result[:questions].size.should eq(2)

      pq_to_move = Pq.find_by(uin: 'PQ_TO_MOVE')
      pq_to_move.progress.name.should eq(Progress.DRAFT_PENDING)

      pq_to_stay = Pq.find_by(uin: 'PQ_TO_STAY')
      pq_to_stay.progress.name.should eq(Progress.ACCEPTED)

      pq_unallocated = Pq.find_by(uin: 'HL784845')
      pq_unallocated.progress.name.should eq(Progress.UNASSIGNED)


    end


  end
end
