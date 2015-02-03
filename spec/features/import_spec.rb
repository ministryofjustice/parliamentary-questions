require 'spec_helper'
require 'helpers/pqa/question_builder'
require 'helpers/pqa/question_loader'

describe PQA::Import do
  let(:loader) {
    PQA::QuestionLoader.new
  }

  let(:from_date) {
    Date.parse('2/2/2015')
  }

  let(:to_date) {
    Date.parse('3/2/2015')
  }

  let(:import) {
    PQA::Import.new
  }

  feature "importing PQA data into the app", type: :request do
    context "when no questions exist in the db" do
      before do
        questions = [
          "2/2/2015",
          "3/2/2015",
          "3/2/2015"
        ].map.with_index do |s, i|
          d = DateTime.parse(s)
          PQA::QuestionBuilder.date_for_answer("uin-#{i}", d)
        end
        loader.load(questions)
      end

      it "saves the new records, rejecting the invalid ones"
    end

    context "when some questions already exist" do
      it "saves the new records, updating the existing ones"
      it "flags questions for which the date for answer has passed"
      it "re-calculates the dates for answer"
    end
  end
end
