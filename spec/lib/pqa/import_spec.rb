require 'feature_helper'

describe PQA::Import do
  def loader
    PQA::QuestionLoader.new
  end

  def from_date
    Date.parse('1/2/2015')
  end

  def to_date
    Date.parse('4/2/2015')
  end

  def import
    PQA::Import.new
  end

  def questions(uin_date_strings)
    uin_date_strings.map do |uin, (tabled_date_s, date_for_answer_s)|
      q = PQA::QuestionBuilder.default(uin)
      q.updated_date    = DateTime.parse(tabled_date_s)
      q.tabled_date     = DateTime.parse(tabled_date_s)
      q.date_for_answer = DateTime.parse(date_for_answer_s)
      q
    end
  end

  feature "importing PQA data into the app" do
    before(:all) do
      DBHelpers.load_spec_fixtures
    end

    context "when no questions exist in the db" do
      before do
        ds = {
          'uin-0' => ["2/2/2015", "3/2/2015"],
          'uin-1' => ["3/2/2015", "4/2/2015"],
          'uin-2' => ["3/2/2015", "4/2/2015"]
        }
        loader.load(questions(ds))
      end

      it "reports that new records have been created" do
        report = import.run(from_date, to_date)
        expect(report).to eq({
          total: 3,
          created: 3,
          updated: 0,
          errors: {}
        })
      end

      it "saves the records and flags them as 'unassigned'" do
        import.run(from_date, to_date)
        expect(Pq.order(:uin).map { |pq| [pq.uin, pq.state] }).to eq([
          ['uin-0', PQState::UNASSIGNED],
          ['uin-1', PQState::UNASSIGNED],
          ['uin-2', PQState::UNASSIGNED]
        ])
      end
    end

    context "when some questions already exist" do
      before do
        # first import
        loader.load(questions({
          'uin-0' => ["2/2/2015", "3/2/2015"],
          'uin-1' => ["3/2/2015", "4/2/2015"]
        }))

        import.run(from_date, to_date)
        # second import
        loader.load(questions({
          'uin-0' => ["1/2/2015","2/2/2015"],
          'uin-1' => ["3/2/2015","4/2/2015"],
          'uin-2' => ["4/2/2015","7/2/2015"]
        }))
      end

      it "reports created and updated records" do
        report = import.run(from_date, to_date)
        expect(report).to eq({
          total: 3,
          created: 1,
          updated: 2,
          errors: {}
        })
      end

      it "saves the new records, updating the existing ones, without changing the state" do
        import.run(from_date, to_date)
        pq = Pq.find_by(uin: 'uin-1')
        pq.update(state: PQState::REJECTED)

        expect(Pq.order(:uin).map { |pq|
          d      = pq.tabled_date
          state  = pq.state

          [pq.uin, [d.day, d.month, d.year], state]
        }).to eq([
          ['uin-0', [1, 2, 2015], PQState::UNASSIGNED],
          ['uin-1', [3, 2, 2015], PQState::REJECTED],
          ['uin-2', [4, 2, 2015], PQState::UNASSIGNED]
        ])
      end
    end

    context 'importing a single question' do
      
      before(:each) do
        # first import
        loader.load(questions({
          'uin-0' => ["2/2/2015", "3/2/2015"],
          'uin-1' => ["3/2/2015", "4/2/2015"]
        }))
      end

      context 'specifying a question that doesnt exists' do
        it 'should return 404' do
          expect {
            report = import.run_for_question('xyz-1234')
          }.to raise_error HTTPClient::FailureResponse, /PQ rest API responded with non success code: 404, response: Not found/
        end
      end

      context 'specifying a question that does exist' do
        it 'should update the question and return the report' do
          report = import.run_for_question('uin-1')
          expect(report[:total]).to eq 1
          expect(report[:created]).to eq 1
          expect(report[:updated]).to eq 0
          expect(report[:errors]).to be_empty
        end
      end
    end
  end
end
