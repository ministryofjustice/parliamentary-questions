require "rails_helper"

describe PQA::XmlDecoder do
  describe "#decode_questions" do
    let(:questions) { described_class.decode_questions(xml) }

    let(:xml) do
      date = Time.zone.parse("28/02/2014")
      questions =
        # 3.times.map do |n|
        Array.new(3) do |n|
          PQA::QuestionBuilder.updated("q-#{n}", date + n.day)
        end
      PQA::XmlEncoder.encode_questions(questions)
    end

    let(:xml_no_question) { "<questions/>" }

    context "when the supplied XML contains no <question> element" do
      it "returns an empty list" do
        expect(described_class.decode_questions(xml_no_question)).to eq([])
      end
    end

    context "when the supplied XML contains some <question> elements" do
      it "parses questions with the correct uin values" do
        expect(questions.map(&:uin)).to eq(%w[q-0 q-1 q-2])
      end

      it "correctly parses dates" do
        expect(
          questions.map do |q|
            d = q.updated_date
            [d.day, d.month, d.year]
          end,
        ).to eq([
          [28, 2, 2014],
          [1,  3, 2014],
          [2,  3, 2014],
        ])
      end
    end

    describe "#decode_answer_response" do
      let(:xml) do
        <<-ANSWER
        <?xml version="1.0" encoding="utf-8"?>
        <AnswerResponse xmlns="http://data.parliament.uk/QnA/2013/02">
          <AnswerPreviewUrl>https://wqa.parliament.uk/Questions/Details/33367</AnswerPreviewUrl>
        </AnswerResponse>
        ANSWER
      end

      describe "#response" do
        it "parses xml and returns an AnswerResponse instance" do
          expect(
            described_class.decode_answer_response(xml).preview_url,
          ).to eq("https://wqa.parliament.uk/Questions/Details/33367")
        end
      end
    end
  end
end
