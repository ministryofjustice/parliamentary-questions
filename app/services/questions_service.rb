class QuestionsService

  def initialize(http_client = QuestionsHttpClient.new)
    @http_client = http_client
  end

  def questions(args = { dateFrom: Date.today} )
    result = ''
    $statsd.time("#{StatsHelper::IMPORT}.qa.response_time") do
      options = {}
      options['dateFrom'] = args[:dateFrom].xmlschema
      options['dateTo'] = args[:dateTo].end_of_day.xmlschema if args[:dateTo].present?
      options['status'] = args[:status] if args[:status].present?
      begin
        response = @http_client.questions(options)
        result = XmlParse.get_xml_data(response,'Question')
      rescue => e
        puts "e=#{e.inspect}"
      end
    end
    result
  end

  def questions_by_uin(uin)
    response = @http_client.question(uin)
    questions = XmlParse.get_xml_data(response,'Question')
    questions.first
  end

  def answer(args)
    uin = args[:uin]
    member_id = args[:member_id]
    text = args[:text]
    is_holding_answer = args[:is_holding_answer] || false

    output = ''
    xml = ::Builder::XmlMarkup.new(:target => output)

    xml.instruct!  :xml, :version=> '1.0', :encoding => 'utf-8'
    xml.Answer('xmlns' => 'http://data.parliament.uk/QnA/2013/02') {
      xml.IsHoldingAnswer is_holding_answer
      xml.Text text
      xml.MinisterId member_id
    }

    response = @http_client.answer(uin, output)

    if response[:status] != 200
      return {error: parse_answer_error_xml(response[:content]) }
    end

    preview_url = parse_answer_xml(response[:content])
    {preview_url: preview_url }
  end

protected

  def parse_answer_xml(response)
    xml  = Nokogiri::XML(response)
    xml.remove_namespaces!
    xml.xpath('/AnswerResponse/AnswerPreviewUrl').text
  end

  def parse_answer_error_xml(response)
    xml  = Nokogiri::XML(response)
    xml.remove_namespaces!
    xml.xpath('/Error/Message').text
  end
end
