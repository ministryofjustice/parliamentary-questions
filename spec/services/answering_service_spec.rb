require 'spec_helper'

describe 'AnsweringService' do
  let(:uin) { '183366' }

  let(:minister) { double('minister', member_id: 1) }

  let(:preview_url) {
    'http://example.com/preview/url'
  }

  let(:answer_response) {
    double('answer-response', preview_url: preview_url )
  }

  let(:pqa_service) {
    srv = double('pqa-service')
    allow(srv).to receive(:answer).with(uin, 1, 'Hello test', true) {
      answer_response
    }
    srv
  }

  let(:pq) {
    double('pq-stub', uin: uin, minister: minister)
  }

  before(:each) do
    allow(PQAService).to receive(:from_settings) {
      pqa_service
    }
  end

  describe '#answer' do
    it 'should insert the answer url in the pq table' do
      service         = AnsweringService.new
      expect(pq).to receive(:update).with(preview_url: preview_url)

      service.answer(pq, text: 'Hello test', is_holding_answer: true)
    end

    context "when minister is nil" do
      let(:minister) { nil }

      it 'should raise an error' do
        expect {
          AnsweringService.new.answer(pq, text: 'Hello test', is_holding_answer: true)
        }.to raise_error(RuntimeError, /minister is not selected/i)
      end
    end

    context "when member_id is nil" do
      let(:minister) { double('minister', member_id: nil) }

      it 'should raise an error' do
        expect {
          AnsweringService.new.answer(pq, text: 'Hello test', is_holding_answer: true)
        }.to raise_error(RuntimeError, /minister is not selected/i)
      end
    end
  end
end
