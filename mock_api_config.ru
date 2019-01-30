$LOAD_PATH << File.expand_path('lib', __dir__)

require 'nokogiri'
require 'net/http'
require 'uri'

require 'xml_extractor'
require 'pqa'
require 'pqa/xml_encoder'
require 'pqa/xml_decoder'
require 'pqa/answer'
require 'pqa/answer_response'
require 'pqa/question'
require 'pqa/mock_api_server'

run PQA::MockApiServer
