require 'spec_helper'

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
        expect(Pq.order(:uin).map { |pq| [pq.uin, pq.progress.name] }).to eq([
          ['uin-0', Progress.UNASSIGNED],
          ['uin-1', Progress.UNASSIGNED],
          ['uin-2', Progress.UNASSIGNED]
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

      it "saves the new records, updating the existing ones, without changing the progress" do
        import.run(from_date, to_date)
        pq = Pq.find_by(uin: 'uin-1')
        pq.update(progress: Progress.rejected)

        expect(Pq.order(:uin).map {|pq|
          d      = pq.tabled_date
          status = pq.progress.name

          [pq.uin, [d.day, d.month, d.year], status]
        }).to eq([
          ['uin-0', [1, 2, 2015], Progress.UNASSIGNED],
          ['uin-1', [3, 2, 2015], Progress.REJECTED],
          ['uin-2', [4, 2, 2015], Progress.UNASSIGNED]
        ])
      end

      context "when some the 'date_for_answer' of some question has expired" do
        before do
          allow(Date).to receive(:today) { Date.parse('5/2/2015') }
          import.run(from_date, to_date)
        end

        it "flags questions for which the date for answer has passed" do
          expect(Pq.order(:uin).pluck(:uin, :date_for_answer_has_passed)).to eq([
            ['uin-0', true],
            ['uin-1', true],
            ['uin-2', false]
          ])
        end
      end

    end

    context "when some question in the API causes a validation error" do
      it "rejects the failing questions and report the validation errors"
    end
  end
end
