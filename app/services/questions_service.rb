class QuestionsService

  def initialize(http_client = QuestionsHttpClient.new)
    @http_client = http_client
  end

  # valid args
  # :dateFrom  YYYY-MM-DDTHH:mm:ss
  # :dateTo    YYYY-MM-DDTHH:mm:ss
  # :status
  #         "Tabled",
  #         "Withdrawn"
  #         "WithdrawnWithoutNotice"
  #         "AnswerNotExpected"
  #         "Incomplete"
  #         "PendingCorrectionReview"
  #         "PendingAnswerReview"
  #         "ReturnedVirus"
  #         "ReturnedCorrection"
  #         "ReturnedAnswer"
  #         "Answered"
  #         "Holding"
  #         "ScanningForVirus"
  def questions(args = { dateFrom: Date.today} )
    t_start = Time.now

    format = "%Y-%m-%dT%H:%M:%S"
    options = {}
    options["dateFrom"] = args[:dateFrom].strftime(format)
    options["dateTo"] = args[:dateTo].strftime(format) if args[:dateTo].present?
    options["status"] = args[:status] if args[:status].present?

    response = @http_client.questions(options)

    result = parse_questions_xml(response)

    # log the time in statsd
    elapsed_seconds = Time.now - t_start
    $statsd.timing("#{StatsHelper::IMPORT}.qa.response_time", elapsed_seconds * 1000)

    return result
  end

  def questions_by_uin(uin)
    response = @http_client.question(uin)
    questions = parse_questions_xml(response)
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

  def parse_questions_xml(response)
    xml  = Nokogiri::XML(response)
    xml.remove_namespaces! # easy to parse if we are only using one namespace
    questions_xml = xml.xpath('//Question')

    questions = Array.new

    questions_xml.each do |q|
      item = Hash.from_xml(q.to_xml)
      questions.push(item["Question"])
    end
    questions
  end


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