require 'spec_helper'

describe PQA::XMLDecoder do
  describe "#decode_questions" do
    let(:xml) {
      date      = DateTime.parse('28/02/2014')
      questions = 3.times.map { |n|
        PQA::QuestionBuilder.updated("q-#{n}", date + n.day)
      }
      PQA::XMLEncoder.encode_questions(questions)
    }

    let(:xml_no_question) {
      "<questions/>"
    }

    let(:questions) {
      PQA::XMLDecoder.decode_questions(xml)
    }

    context "when the supplied XML contains no <question> element" do
      it "returns an empty list" do
        expect(PQA::XMLDecoder.decode_questions(xml_no_question)).to eq([])
      end
    end

    context "when the supplied XML contains some <question> elements" do
      it "parses questions with the correct uin values" do
        expect(questions.map(&:uin)).to eq([
          'q-0','q-1','q-2'
        ])
      end

      it "correctly parses dates" do
        expect(
          questions.map do |q|
            d = q.updated_date
            [d.day, d.month, d.year]
          end
        ).to eq([
          [28, 2, 2014],
          [1,  3, 2014],
          [2,  3, 2014]
        ])
      end
    end

    describe "#decode_answer_response" do
      let(:xml) {
        <<-EOS
        <?xml version="1.0" encoding="utf-8"?>
        <AnswerResponse xmlns="http://data.parliament.uk/QnA/2013/02">
          <AnswerPreviewUrl>https://wqa.parliament.uk/Questions/Details/33367</AnswerPreviewUrl>
        </AnswerResponse>
        EOS
      }

      describe "#response" do
        it "parses xml and returns an AnswerResponse instance" do
          expect(
            PQA::XMLDecoder.decode_answer_response(xml).preview_url
          ).to eq('https://wqa.parliament.uk/Questions/Details/33367')
        end
      end
    end
  end
end
