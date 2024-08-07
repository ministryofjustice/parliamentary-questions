require "rails_helper"

describe PQA::Import do
  def loader
    PQA::QuestionLoader.new
  end

  def from_date
    Date.parse("1/2/2015")
  end

  def to_date
    Date.parse("4/2/2015")
  end

  def import
    PQA::Import.new(loader.client)
  end

  def questions(uin_date_strings)
    uin_date_strings.map do |uin, (tabled_date_s, date_for_answer_s)|
      q = PQA::QuestionBuilder.default(uin)
      q.updated_date    = Time.zone.parse(tabled_date_s)
      q.tabled_date     = Time.zone.parse(tabled_date_s)
      q.date_for_answer = Time.zone.parse(date_for_answer_s)
      q
    end
  end

  describe "importing PQA data into the app" do
    before do
      DbHelpers.load_spec_fixtures
    end

    context "when no questions exist in the db" do
      before do
        ds = {
          "uin-0" => ["2/2/2015", "3/2/2015"],
          "uin-1" => ["3/2/2015", "4/2/2015"],
          "uin-2" => ["3/2/2015", "4/2/2015"],
        }
        loader.load(questions(ds))
      end

      it "reports that new records have been created" do
        report = import.run(from_date, to_date)
        expect(report).to eq(
          total: 3,
          created: 3,
          updated: 0,
          errors: {},
        )
      end

      it "saves the records and flags them as 'unassigned'" do
        import.run(from_date, to_date)
        expect(Pq.order(:uin).map { |pq| [pq.uin, pq.state] }).to eq([
          ["uin-0", PqState::UNASSIGNED],
          ["uin-1", PqState::UNASSIGNED],
          ["uin-2", PqState::UNASSIGNED],
        ])
      end
    end

    context "when some questions already exist" do
      before do
        # first import
        loader.load(questions(
                      "uin-0" => ["2/2/2015", "3/2/2015"],
                      "uin-1" => ["3/2/2015", "4/2/2015"],
                    ))

        import.run(from_date, to_date)
        # second import
        loader.load(questions(
                      "uin-0" => ["1/2/2015", "2/2/2015"],
                      "uin-1" => ["3/2/2015", "4/2/2015"],
                      "uin-2" => ["4/2/2015", "7/2/2015"],
                    ))
      end

      it "reports created and updated records" do
        report = import.run(from_date, to_date)
        expect(report).to eq(
          total: 3,
          created: 1,
          updated: 2,
          errors: {},
        )
      end

      it "saves the new records, updating the existing ones, without changing the state" do
        import.run(from_date, to_date)
        Pq.find_by(uin: "uin-1").update!(state: PqState::REJECTED)

        expect(Pq.order(:uin).map do |pq|
          d = pq.tabled_date
          state = pq.state
          [pq.uin, [d.day, d.month, d.year], state]
        end).to eq([
          ["uin-0", [1, 2, 2015], PqState::UNASSIGNED],
          ["uin-1", [3, 2, 2015], PqState::REJECTED],
          ["uin-2", [4, 2, 2015], PqState::UNASSIGNED],
        ])
      end
    end

    context "when importing a single question" do
      before do
        # first import
        loader.load(questions(
                      "uin-0" => ["2/2/2015", "3/2/2015"],
                      "uin-1" => ["3/2/2015", "4/2/2015"],
                    ))
      end

      context "when specifying a question that does exist" do
        it "updates the question and return the report" do
          report = import.run_for_question("uin-1")
          expect(report[:total]).to eq 1
          expect(report[:created]).to eq 1
          expect(report[:updated]).to eq 0
          expect(report[:errors]).to be_empty
        end
      end
    end
  end
end
