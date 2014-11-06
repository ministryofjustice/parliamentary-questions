require 'spec_helper'

describe 'QuestionsHttpClient' do
  before(:each) do
    Settings.http_client_timeout = 20
    @http_client = QuestionsHttpClient.new
  end

  it 'should generate an error if the content is not valid xml' do
    expect{@http_client.questions('dateFrom' => 'Force error')}.to raise_error('API response non-valid')
  end

  it 'should send an email if the API call fails' do
    ActionMailer::Base.deliveries = []
    expect{@http_client.questions('dateFrom' => 'Force error')}.to raise_error('API response non-valid')
    mail = ActionMailer::Base.deliveries.first
    mail.subject.should eql('API import failed')
    mail.html_part.body.should include 'It returned status code'
  end

  xit 'should return a timeout error if the API is unavailable' do
    Settings.http_client_timeout = 2
    @http_client = QuestionsHttpClient.new('http://mock-pq-api.herokuapp.com:8999',nil,nil)
    expect{@http_client.questions('dateFrom' => 'Force error')}.to raise_error('API connection timed-out')
  end

  it 'should return a timeout error if the API takes to long to respond' do
    @http_client.set_receive_timeout(0.000001)
    expect{@http_client.questions('dateFrom' => '2000-01-01')}.to raise_error('API response timed-out')
  end

  xit 'should get an xml response from the PQ API' do
    questions_xml = @http_client.questions('dateFrom' => '2014-04-17')
    questions_xml.should include('<Questions')
  end

  xit 'should get a question in xml response from the PQ API' do
    questions_xml = @http_client.question('157551')
    questions_xml.should include('<Uin>157551</Uin>')
  end

  xit 'should get a question in xml response from the PQ API' do
    body = '<?xml version="1.0" encoding="utf-8"?>
            <Answer xmlns="http://data.parliament.uk/QnA/2013/02">
              <IsHoldingAnswer>false</IsHoldingAnswer>
              <Text>Test from ruby</Text>
              <MinisterId>1413</MinisterId>
            </Answer>'

    result = @http_client.answer('183366', body)
    result[:content].should include('<AnswerResponse')
  end

  xit 'should submit the answer using the question_service' do
    service = QuestionsService.new(@http_client)
    result = service.answer(uin: '183366', text: 'Test from questions service', member_id: '1413', is_holding_answer: true)
    result.should_not be nil
  end
end
