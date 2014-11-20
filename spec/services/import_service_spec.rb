require 'spec_helper'

describe 'ImportService' do
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
      expect(import_result[:questions].size).to eq(1)

      question_one = Pq.find_by(uin: 'HL784845')
      expect(question_one).to_not be_nil
      expect(question_one.raising_member_id).to eq 2479
      expect(question_one.question).to eq 'Hello we are asking questions'
    end
  end

  describe '#today_questions' do
    it 'should not fail if 0 questions returned' do
      allow(@http_client).to receive(:questions) { empty_questions_for_today }

      import_result = @import_service.questions()
      expect(import_result[:questions].size).to eq(0)
    end

    it 'should store today questions into the data model' do
      import_result = @import_service.questions()
      expect(import_result[:questions].size).to eq(2)

      question_one = Pq.find_by(uin: 'HL784845')
      expect(question_one).to_not be_nil
      expect(question_one.raising_member_id).to eq 2479
      expect(question_one.question).to eq 'Hello we are asking questions'

      expect(question_one.member_name).to eq 'Diana Johnson'
      expect(question_one.member_constituency).to eq 'Kingston upon Hull North'
      expect(question_one.house_name).to eq 'House of Lords'
      expect(question_one.date_for_answer).to eq Date.new(2013, 1, 27)
      expect(question_one.registered_interest).to be(false)
      expect(question_one.tabled_date).to eq Date.new(2013, 1, 22)


      expect(question_one.question_type).to eq 'NamedDay'
      expect(question_one.preview_url).to eq 'https://wqatest.parliament.uk/Questions/Details/37988'

      expect(question_one.transferred).to be(false)

      expect(question_one.question_status).to eq('Tabled')

      question_two = Pq.find_by(uin: 'HL673892')
      expect(question_two).to_not be_nil
      expect(question_two.raising_member_id).to eq 9742
      expect(question_two.question).to eq "I'm asking questions too"
    end

    it 'should update the question data if #today_questions is called multiple times' do
      # First call
      import_result = @import_service.questions()
      expect(import_result[:questions].size).to eq(2)

      question_one = Pq.find_by(uin: 'HL784845')
      expect(question_one).to_not be_nil
      expect(question_one.question).to eq 'Hello we are asking questions'

      question_two = Pq.find_by(uin: 'HL673892')
      expect(question_two).to_not be_nil
      expect(question_two.question).to eq "I'm asking questions too"

      # Second call, with different xml response
      allow(@http_client).to receive(:questions) { import_questions_for_today_with_changes }

      @import_service.questions

      question_one = Pq.find_by(uin: 'HL784845')
      expect(question_one).to_not be_nil
      expect(question_one.question).to eq 'Hello we are asking questions'

      question_two = Pq.find_by(uin: 'HL673892')
      expect(question_two).to_not be_nil
      # The question text is different now
      expect(question_two.question).to eq "The Text Changed"

    end


    it 'should create new question, if you get new questions from the api' do

      # First call
      import_result = @import_service.questions()
      expect(import_result[:questions].size).to eq(2)

      question_one = Pq.find_by(uin: 'HL784845')
      expect(question_one).to_not be_nil
      expect(question_one.question).to eq 'Hello we are asking questions'

      question_two = Pq.find_by(uin: 'HL673892')
      expect(question_two).to_not be_nil
      expect(question_two.question).to eq "I'm asking questions too"

      question_new = Pq.find_by(uin: 'HL5151')
      expect(question_new).to be_nil

      # Second call, with one new question
      allow(@http_client).to receive(:questions) { import_questions_for_today_with_changes }

      @import_service.questions()

      question_new = Pq.find_by(uin: 'HL5151')
      expect(question_new).to_not be_nil
      expect(question_new.question).to eq 'New question in the api'
    end

    it 'should store audit events by name when importing' do
      PaperTrail.enabled = true
      PaperTrail.whodunnit = 'TestRunner'
      import_result = @import_service.questions()
      expect(import_result[:questions].size).to eq(2)

      question_one = Pq.find_by(uin: 'HL784845')
      update = question_one.versions.last
      expect(question_one.versions.size).to eq 2 # Create and update
      expect(update.whodunnit).to eq 'TestRunner'
    end

    it 'should return error hash when sent malformed XML from api' do
      allow(@http_client).to receive(:questions) { import_questions_for_today_with_missing_uin }
      import_result = @import_service.questions()

      expect(import_result[:questions].size).to eq 1

      errors = import_result[:errors]
      expect(errors.size).to eq 1

      err = errors.first

      expect(err[:message]).to eq ["Uin can't be blank"]
      question_with_error = err[:question]

      expect(question_with_error['Text']).to eq "I'm asking questions too"
      expect(question_with_error['Uin']).to be_nil
    end

    it 'should not overwrite the question internal_deadline' do
      import_result = @import_service.questions()
      expect(import_result[:questions].size).to eq(2)

      question_one = Pq.find_by(uin: 'HL784845')
      expect(question_one).to_not be_nil

      question_one.internal_deadline = DateTime.new(2012, 8, 29,  0,  0,  0)
      question_one.save()

      import_result = @import_service.questions()
      question_one = Pq.find_by(uin: 'HL784845')
      expect(question_one).to_not be_nil
      expect(question_one.internal_deadline).to eq DateTime.new(2012, 8, 29)
    end

    it 'should create the question in Unallocated state' do
      import_result = @import_service.questions()
      expect(import_result[:questions].size).to eq(2)

      question_one = Pq.find_by(uin: 'HL784845')
      expect(question_one).to_not be_nil

      expect(question_one.progress.name).to eq(Progress.UNASSIGNED)
    end

    it 'should move questions from Accepted to Draft Pending' do
      pq = create(:pq, uin: 'PQ_TO_MOVE', question: 'test question?', progress_id: Progress.accepted.id)
      ao = create(:action_officer, name: 'ao name 1', email: 'ao@ao.gov')
      yesterday = DateTime.now - 1.day
      ActionOfficersPq.create(action_officer_id: ao.id, pq_id: pq.id, accept: true, reject: false, updated_at: yesterday)

      pq = create(:pq, uin: 'PQ_TO_STAY', question: 'test question?', progress_id: Progress.accepted.id)
      ActionOfficersPq.create(action_officer_id: ao.id, pq_id: pq.id, accept: true, reject: false, updated_at: DateTime.now)

      import_result = @import_service.questions()
      expect(import_result[:questions].size).to eq(2)

      pq_to_move = Pq.find_by(uin: 'PQ_TO_MOVE')
      expect(pq_to_move.progress.name).to eq(Progress.DRAFT_PENDING)

      pq_to_stay = Pq.find_by(uin: 'PQ_TO_STAY')
      expect(pq_to_stay.progress.name).to eq(Progress.ACCEPTED)

      pq_unallocated = Pq.find_by(uin: 'HL784845')
      expect(pq_unallocated.progress.name).to eq(Progress.UNASSIGNED)
    end

    it 'should not overwrite the question date_for_answer' do
      import_result = @import_service.questions()
      expect(import_result[:questions].size).to eq(2)

      question_one = Pq.find_by(uin: 'HL784845')
      expect(question_one).to_not be_nil

      question_one.date_for_answer = DateTime.new(2012, 8, 29,  0,  0,  0)
      question_one.save()

      import_result = @import_service.questions()
      question_one = Pq.find_by(uin: 'HL784845')
      expect(question_one).to_not be_nil
      expect(question_one.date_for_answer).to eq Date.new(2012, 8, 29)
    end
  end
end
