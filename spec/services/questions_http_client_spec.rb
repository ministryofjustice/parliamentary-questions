require 'spec_helper'

describe QuestionsHttpClient do
  # before(:each) do
  #   stub_request(:get, "http://username:password@pq_rest_api_url#{path}?#{query}").
  #     to_return(:status => 200, :body => body)
  # end

  def build_url(query)
    url = Settings.pq_rest_api.url
    username = Settings.pq_rest_api.username
    password = Settings.pq_rest_api.password
    "http://#{username}:#{password}@#{url.gsub('http://', '')}/api/qais#{query}"
  end

  def question_url(query)
    build_url("/questions#{query}")
  end

  def answer_url(query)
    build_url("/answers#{query}")
  end

  context 'when API call fails' do
    before { stub_request(:get, question_url('?dateFrom=2001-01-01')).to_return(status: 500) }

    it 'generates an error' do
      expect{ subject.questions('dateFrom' => '2001-01-01') }.to raise_error('API response non-valid')
    end

    it 'sends an email' do
      ActionMailer::Base.deliveries = []
      expect{ subject.questions('dateFrom' => '2001-01-01') }.to raise_error
      mail = ActionMailer::Base.deliveries.first
      expect(mail.subject).to eql('API import failed')
      expect(mail.html_part.body).to include 'It returned status code'
    end
  end

  it 'returns a timeout error if the API is unavailable' do
    stub_request(:get, question_url('?dateFrom=2001-01-01')).to_raise HTTPClient::ConnectTimeoutError
    expect{ subject.questions('dateFrom' => '2001-01-01') }.to raise_error('API connection timed-out')
  end

  it 'returns a timeout error if the API takes to long to respond' do
    stub_request(:get, question_url('?dateFrom=2001-01-01')).to_raise HTTPClient::ReceiveTimeoutError
    expect{ subject.questions('dateFrom' => '2001-01-01') }.to raise_error('API response timed-out')
  end

  it 'gets an xml response from the PQ API' do
    stub_request(:get, question_url('?dateFrom=2001-01-01')).to_return(body: File.read('spec/fixtures/questions.xml'))
    questions_xml = subject.questions('dateFrom' => '2001-01-01')
    expect(questions_xml).to include('<Questions')
  end

  it 'gets a question in xml response from the PQ API' do
    stub_request(:get, question_url('/HL4837')).to_return(body: File.read('spec/fixtures/questions_by_uin.xml'))
    questions_xml = subject.question('HL4837')
    expect(questions_xml).to include('<Uin>HL4837</Uin>')
  end

  it 'gets a question in xml response from the PQ API' do
    answer = 'answer'
    stub_request(:put, answer_url('/183366')).with(body: answer).to_return body: 'Response'

    result = subject.answer('183366', answer)
    expect(result[:content]).to eq('Response')
  end
end
